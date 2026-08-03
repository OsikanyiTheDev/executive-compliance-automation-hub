# Setup Guide — Phase 0 Recovery

This guide shows you the exact file contents to create on your local machine. The sandbox where I run is separate from your local machine, so files I create with `write_file` exist in `/home/user/` in the sandbox, not on your local `~/Desktop/personal-projects/...` directory.

## File: `python/helpers/__init__.py`

**Content:** (leave empty, just create the file)

```python
# This file is intentionally empty.
# It marks python/helpers/ as a Python package.
```

## File: `python/helpers/environment.py`

**Full content:**

```python
"""
environment.py — Environment configuration loader.
"""

import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class Config:
    n8n_host: str
    n8n_port: int
    n8n_protocol: str
    timezone: str
    aws_region: str
    s3_bucket_name: str
    encryption_key: Optional[str]
    anthropic_api_key: Optional[str]


def get_config() -> Config:
    return Config(
        n8n_host=os.getenv("N8N_HOST", "localhost"),
        n8n_port=int(os.getenv("N8N_PORT", "5678")),
        n8n_protocol=os.getenv("N8N_PROTOCOL", "http"),
        timezone=os.getenv("GENERIC_TIMEZONE", "UTC"),
        aws_region=os.getenv("AWS_REGION", "us-east-1"),
        s3_bucket_name=os.getenv("S3_BUCKET_NAME", "executive-compliance-documents"),
        encryption_key=os.getenv("N8N_ENCRYPTION_KEY"),
        anthropic_api_key=os.getenv("ANTHROPIC_API_KEY"),
    )


def validate_config(config: Config) -> list:
    errors = []
    if not config.encryption_key:
        errors.append("N8N_ENCRYPTION_KEY is not set")
    if not config.anthropic_api_key:
        errors.append("ANTHROPIC_API_KEY is not set (required for AI workflows)")
    return errors


if __name__ == "__main__":
    config = get_config()
    print("Current Configuration:")
    print(f"  n8n URL: {config.n8n_protocol}://{config.n8n_host}:{config.n8n_port}")
    print(f"  Timezone: {config.timezone}")
    print(f"  AWS Region: {config.aws_region}")
    print(f"  S3 Bucket: {config.s3_bucket_name}")
    print(f"  AI Provider: {'Configured' if config.anthropic_api_key else 'Not configured'}")
    errors = validate_config(config)
    if errors:
        print("\nConfiguration Issues:")
        for error in errors:
            print(f"  - {error}")
    else:
        print("\nAll required configuration is present.")
```

## File: `tests/__init__.py`

**Content:** (empty)

## File: `tests/unit/__init__.py`

**Content:** (empty)

## File: `tests/unit/test_environment.py`

**Full content:**

```python
"""Unit tests for environment configuration loader."""
import os
import pytest
from python.helpers.environment import get_config, validate_config, Config


class TestGetConfig:
    def test_returns_config_object(self):
        assert isinstance(get_config(), Config)

    def test_default_n8n_port(self):
        os.environ.pop("N8N_PORT", None)
        assert get_config().n8n_port == 5678

    def test_default_aws_region(self):
        os.environ.pop("AWS_REGION", None)
        assert get_config().aws_region == "us-east-1"

    def test_respects_environment_variables(self, monkeypatch):
        monkeypatch.setenv("N8N_HOST", "example.com")
        monkeypatch.setenv("AWS_REGION", "eu-west-1")
        config = get_config()
        assert config.n8n_host == "example.com"
        assert config.aws_region == "eu-west-1"

    def test_optional_fields_default_to_none(self):
        os.environ.pop("N8N_ENCRYPTION_KEY", None)
        os.environ.pop("ANTHROPIC_API_KEY", None)
        config = get_config()
        assert config.encryption_key is None
        assert config.anthropic_api_key is None


class TestValidateConfig:
    def test_missing_encryption_key_reported(self):
        config = Config("localhost", 5678, "http", "UTC", "us-east-1", "bucket", None, "key")
        assert "N8N_ENCRYPTION_KEY is not set" in validate_config(config)

    def test_missing_ai_key_reported(self):
        config = Config("localhost", 5678, "http", "UTC", "us-east-1", "bucket", "key", None)
        assert "ANTHROPIC_API_KEY is not set (required for AI workflows)" in validate_config(config)

    def test_all_present_returns_empty(self):
        config = Config("localhost", 5678, "http", "UTC", "us-east-1", "bucket", "k", "k")
        assert validate_config(config) == []
```

## After Creating These Files

```bash
# Make sure venv is active
source venv/bin/activate

# Run the tests
pytest tests/ -v

# Expected: 8 passed
```
