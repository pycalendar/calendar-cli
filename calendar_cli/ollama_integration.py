#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ollama integration for calendar-cli
Allows adding events and tasks using natural language
"""

import json
import requests
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List
import re


class OllamaClient:
    """Client for interacting with Ollama API"""

    def __init__(self, base_url: str = "http://localhost:11434"):
        """
        Initialize Ollama client

        Args:
            base_url: Base URL for Ollama API (default: http://localhost:11434)
        """
        self.base_url = base_url.rstrip('/')
        self.api_url = f"{self.base_url}/api"

    def is_available(self) -> bool:
        """Check if Ollama is running and available"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=2)
            return response.status_code == 200
        except requests.RequestException:
            return False

    def list_models(self) -> List[str]:
        """List available models"""
        try:
            response = requests.get(f"{self.api_url}/tags", timeout=5)
            if response.status_code == 200:
                data = response.json()
                return [model['name'] for model in data.get('models', [])]
            return []
        except requests.RequestException:
            return []

    def generate(self, prompt: str, model: str = "llama2", stream: bool = False) -> Dict[str, Any]:
        """
        Generate text using Ollama

        Args:
            prompt: The prompt to send to the model
            model: Model name to use (default: llama2)
            stream: Whether to stream the response

        Returns:
            Dictionary containing the response
        """
        payload = {
            "model": model,
            "prompt": prompt,
            "stream": stream,
            "format": "json"
        }

        try:
            response = requests.post(
                f"{self.api_url}/generate",
                json=payload,
                timeout=60
            )

            if response.status_code == 200:
                if stream:
                    return {"response": response.text}
                else:
                    return response.json()
            else:
                return {
                    "error": f"HTTP {response.status_code}: {response.text}",
                    "response": ""
                }
        except requests.RequestException as e:
            return {
                "error": f"Request failed: {str(e)}",
                "response": ""
            }


class NaturalLanguageParser:
    """Parse natural language into calendar events and tasks"""

    def __init__(self, ollama_client: OllamaClient, model: str = "llama2"):
        """
        Initialize parser

        Args:
            ollama_client: OllamaClient instance
            model: Model to use for parsing
        """
        self.ollama = ollama_client
        self.model = model

    def parse_event(self, text: str) -> Dict[str, Any]:
        """
        Parse natural language text into event/task information

        Args:
            text: Natural language text (e.g., "Rendez-vous dentiste demain à 14h")

        Returns:
            Dictionary with parsed information:
            {
                "type": "event" or "task",
                "summary": "description",
                "date": "YYYY-MM-DD",
                "time": "HH:MM" (optional),
                "duration": "2h" (optional),
                "due_date": "YYYY-MM-DD" (for tasks),
                "priority": 1-5 (for tasks),
                "alarm": "1h" (optional)
            }
        """
        today = datetime.now().strftime("%Y-%m-%d")

        prompt = f"""Tu es un assistant qui extrait des informations structurées à partir de texte en langage naturel pour créer des événements de calendrier ou des tâches.

Date du jour: {today}

Texte à analyser: "{text}"

Extrait les informations suivantes au format JSON:
- "type": "event" (rendez-vous, réunion) ou "task" (tâche, todo, à faire)
- "summary": description courte de l'événement/tâche
- "date": date au format YYYY-MM-DD (calcule la date si relative comme "demain", "lundi prochain", etc.)
- "time": heure au format HH:MM si mentionnée (format 24h)
- "duration": durée si mentionnée (format: "1h", "30m", "2h30m")
- "due_date": date d'échéance pour les tâches (format YYYY-MM-DD)
- "priority": priorité de 1 (basse) à 5 (haute) si mentionnée ou devinée du contexte
- "alarm": rappel si mentionné (format: "1h", "30m", "1d" pour 1 jour avant)

Exemples:
"Rendez-vous dentiste demain à 14h" -> {{"type": "event", "summary": "Rendez-vous dentiste", "date": "2025-10-22", "time": "14:00"}}
"Réunion équipe lundi 10h pour 2 heures" -> {{"type": "event", "summary": "Réunion équipe", "date": "2025-10-27", "time": "10:00", "duration": "2h"}}
"Acheter du pain" -> {{"type": "task", "summary": "Acheter du pain", "priority": 3}}
"Finir le rapport pour vendredi" -> {{"type": "task", "summary": "Finir le rapport", "due_date": "2025-10-24", "priority": 4}}
"Appeler Marie après-demain" -> {{"type": "task", "summary": "Appeler Marie", "due_date": "2025-10-23", "priority": 3}}

Réponds UNIQUEMENT avec le JSON, sans autre texte."""

        result = self.ollama.generate(prompt, model=self.model)

        if "error" in result:
            raise Exception(f"Ollama error: {result['error']}")

        # Extract JSON from response
        response_text = result.get("response", "")

        try:
            # Try to parse directly
            parsed = json.loads(response_text)
        except json.JSONDecodeError:
            # Try to find JSON in the response
            json_match = re.search(r'\{[^}]+\}', response_text)
            if json_match:
                parsed = json.loads(json_match.group(0))
            else:
                # Fallback: basic parsing
                parsed = self._fallback_parse(text)

        return parsed

    def _fallback_parse(self, text: str) -> Dict[str, Any]:
        """
        Fallback parsing when Ollama fails
        Uses simple heuristics
        """
        text_lower = text.lower()

        # Determine type
        task_keywords = ['acheter', 'faire', 'finir', 'appeler', 'envoyer', 'tâche', 'todo']
        is_task = any(keyword in text_lower for keyword in task_keywords)

        result = {
            "type": "task" if is_task else "event",
            "summary": text,
            "priority": 3
        }

        # Try to extract date
        today = datetime.now()

        if "demain" in text_lower:
            result["date"] = (today + timedelta(days=1)).strftime("%Y-%m-%d")
        elif "après-demain" in text_lower or "apres-demain" in text_lower:
            result["date"] = (today + timedelta(days=2)).strftime("%Y-%m-%d")
        elif "aujourd'hui" in text_lower or "aujourdhui" in text_lower:
            result["date"] = today.strftime("%Y-%m-%d")

        # Try to extract time (HH:MM or HHh or HHhMM)
        time_pattern = r'(\d{1,2})[h:](\d{2})?'
        time_match = re.search(time_pattern, text)
        if time_match:
            hour = int(time_match.group(1))
            minute = int(time_match.group(2)) if time_match.group(2) else 0
            result["time"] = f"{hour:02d}:{minute:02d}"

        return result


def format_for_calendar_cli(parsed_data: Dict[str, Any]) -> List[str]:
    """
    Convert parsed data into calendar-cli command arguments

    Args:
        parsed_data: Dictionary from parse_event()

    Returns:
        List of command-line arguments for calendar-cli
    """
    event_type = parsed_data.get("type", "event")

    if event_type == "event":
        # Build calendar add command
        args = ["calendar", "add"]

        # Build event_time string
        date = parsed_data.get("date", "")
        time = parsed_data.get("time", "")
        duration = parsed_data.get("duration", "")

        if date and time:
            event_time = f"{date}T{time}"
            if duration:
                event_time += f"+{duration}"
        elif date:
            event_time = date
        else:
            event_time = "today"

        args.append(event_time)
        args.append(parsed_data.get("summary", "Événement"))

        # Add optional parameters
        if parsed_data.get("alarm"):
            args.extend(["--alarm", parsed_data["alarm"]])

    else:  # task
        # Build todo add command
        args = ["todo", "add"]
        args.append(parsed_data.get("summary", "Tâche"))

        # Add optional parameters
        if parsed_data.get("due_date"):
            args.extend(["--set-due", parsed_data["due_date"]])

        if parsed_data.get("priority"):
            args.extend(["--set-priority", str(parsed_data["priority"])])

        if parsed_data.get("alarm"):
            args.extend(["--alarm", parsed_data["alarm"]])

    return args


def test_ollama_connection():
    """Test function to check Ollama availability"""
    client = OllamaClient()

    print("Testing Ollama connection...")
    if client.is_available():
        print("✓ Ollama is running")
        models = client.list_models()
        if models:
            print(f"✓ Available models: {', '.join(models)}")
        else:
            print("⚠ No models found. Install a model with: ollama pull llama2")
        return True
    else:
        print("✗ Ollama is not running or not accessible")
        print("  Start it with: ollama serve")
        return False


if __name__ == "__main__":
    # Simple test
    test_ollama_connection()
