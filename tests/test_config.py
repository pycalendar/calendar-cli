"""Tests for calendar_cli.config.

interactive_config() historically carried a "untested code ahead" warning and
was in fact broken on Python 3 (it referenced the Python 2 raw_input builtin
and used os/time/getpass without importing them).  These tests exercise the
save path so that breakage cannot silently return.
"""
from types import SimpleNamespace
from unittest import mock

from calendar_cli.config import config_section, interactive_config, read_config


def _fake_input(prompt=""):
    """Answer the command prompt with 'save', every other prompt with a value."""
    if "command" in prompt.lower():
        return "save"
    return "somevalue"


class TestInteractiveConfig:
    def test_saves_config_to_disk(self, tmp_path):
        cfg_file = tmp_path / "calendar.conf"
        args = SimpleNamespace(config_section="default", config_file=str(cfg_file))

        with mock.patch("builtins.input", side_effect=_fake_input), \
             mock.patch("calendar_cli.config.getpass", return_value="secretpass"):
            result = interactive_config(args, {}, [])

        assert cfg_file.exists()
        written = read_config(str(cfg_file))
        assert written["default"]["caldav_url"] == "somevalue"
        # the password comes via getpass(), not input()
        assert written["default"]["caldav_pass"] == "secretpass"
        # the returned config matches what was persisted
        assert result["default"]["caldav_url"] == "somevalue"


class TestConfigSection:
    def test_inheritance(self):
        config = {
            "base": {"caldav_url": "https://example.com", "caldav_user": "base"},
            "child": {"inherits": "base", "caldav_user": "child"},
        }
        section = config_section(config, "child")
        # inherited value is present, own value overrides the inherited one
        assert section["caldav_url"] == "https://example.com"
        assert section["caldav_user"] == "child"
