"""
Unit tests for environment configuration loader.

WHY TESTS MATTER:
- Catch bugs before they reach production.
- Document how code is supposed to work.
- Enable safe refactoring (change code with confidence).

TESTING PYRAMID:
- Unit tests: test one function in isolation (fast, many)
- Integration tests: test multiple components together (medium, fewer)
- E2E tests: test the full system (slow, fewest)
"""

import os
import pytest
from python.helpers.environment import get_config, validate_config, Config


class TestGetConfig:
    """Tests for the get_config() function."""

    def test_returns_config_object(self):
        """Should return a Config instance."""
        config = get_config()
        assert isinstance(config, Config)

    def test_default_n8n_port(self):
        """Default n8n port should be 5678."""
        # Clear env var to test default
        os.environ.pop("N8N_PORT", None)
        config = get_config()
        assert config.n8n_port == 5678

    def test_default_aws_region(self):
        """Default AWS region should be us-east-1."""
        os.environ.pop("AWS_REGION", None)
        config = get_config()
        assert config.aws_region == "us-east-1"

    def test_respects_environment_variables(self, monkeypatch):
        """Should read values from environment variables."""
        monkeypatch.setenv("N8N_HOST", "example.com")
        monkeypatch.setenv("AWS_REGION", "eu-west-1")

        config = get_config()

        assert config.n8n_host == "example.com"
        assert config.aws_region == "eu-west-1"

    def test_optional_fields_default_to_none(self):
        """Encryption key and AI key should default to None."""
        os.environ.pop("N8N_ENCRYPTION_KEY", None)
        os.environ.pop("ANTHROPIC_API_KEY", None)

        config = get_config()

        assert config.encryption_key is None
        assert config.anthropic_api_key is None


class TestValidateConfig:
    """Tests for the validate_config() function."""

    def test_missing_encryption_key_reported(self):
        """Should report missing encryption key."""
        config = Config(
            n8n_host="localhost",
            n8n_port=5678,
            n8n_protocol="http",
            timezone="UTC",
            aws_region="us-east-1",
            s3_bucket_name="test-bucket",
            encryption_key=None,
            anthropic_api_key="test-key",
        )
        errors = validate_config(config)
        assert "N8N_ENCRYPTION_KEY is not set" in errors

    def test_missing_ai_key_reported(self):
        """Should report missing AI API key."""
        config = Config(
            n8n_host="localhost",
            n8n_port=5678,
            n8n_protocol="http",
            timezone="UTC",
            aws_region="us-east-1",
            s3_bucket_name="test-bucket",
            encryption_key="some-key",
            anthropic_api_key=None,
        )
        errors = validate_config(config)
        assert "ANTHROPIC_API_KEY is not set (required for AI workflows)" in errors

    def test_all_present_returns_empty(self):
        """Should return empty list when all required config is present."""
        config = Config(
            n8n_host="localhost",
            n8n_port=5678,
            n8n_protocol="http",
            timezone="UTC",
            aws_region="us-east-1",
            s3_bucket_name="test-bucket",
            encryption_key="some-key",
            anthropic_api_key="some-key",
        )
        errors = validate_config(config)
        assert errors == []


# ============================================================
# Run tests with:  pytest tests/unit/test_environment.py -v
# ============================================================
