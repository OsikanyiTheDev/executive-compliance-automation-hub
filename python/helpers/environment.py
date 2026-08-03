"""
environment.py — Environment configuration loader.

WHY THIS FILE EXISTS:
- Centralizes all environment variable access in one place.
- Provides defaults and validation.
- Makes it easy to mock environment in tests.

WHEN TO USE:
- Any Python script that needs config (API keys, endpoints, etc.)
- Any n8n "Execute Command" node that calls Python.

USAGE:
    from python.helpers.environment import get_config

    config = get_config()
    print(config.aws_region)
"""

import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class Config:
    """
    Configuration data class.

    WHY DATACLASS: Type hints + auto-generated __init__ + immutability.
    Interview tip: dataclasses are Python 3.7+ best practice.
    """
    n8n_host: str
    n8n_port: int
    n8n_protocol: str
    timezone: str
    aws_region: str
    s3_bucket_name: str
    encryption_key: Optional[str]
    anthropic_api_key: Optional[str]


def get_config() -> Config:
    """
    Load configuration from environment variables.

    WHY: Single source of truth for all env access.
    HOW: Reads os.environ with sensible defaults.

    Returns:
        Config: A populated configuration object.
    """
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


def validate_config(config: Config) -> list[str]:
    """
    Validate that all required configuration is present.

    WHY: Fail fast at startup, not at runtime when a workflow fails mysteriously.
    HOW: Returns a list of error messages (empty list = all good).

    Returns:
        list[str]: A list of validation errors. Empty if valid.
    """
    errors = []

    if not config.encryption_key:
        errors.append("N8N_ENCRYPTION_KEY is not set")

    if not config.anthropic_api_key:
        errors.append("ANTHROPIC_API_KEY is not set (required for AI workflows)")

    return errors


if __name__ == "__main__":
    # When run directly, print current config (without secrets!)
    config = get_config()
    print("Current Configuration:")
    print(f"  n8n URL: {config.n8n_protocol}://{config.n8n_host}:{config.n8n_port}")
    print(f"  Timezone: {config.timezone}")
    print(f"  AWS Region: {config.aws_region}")
    print(f"  S3 Bucket: {config.s3_bucket_name}")
    print(f"  AI Provider: {'Configured' if config.anthropic_api_key else 'Not configured'}")

    # Run validation
    errors = validate_config(config)
    if errors:
        print("\nConfiguration Issues:")
        for error in errors:
            print(f"  - {error}")
        print("\n(This is expected during initial setup. Configure .env to fix.)")
    else:
        print("\nAll required configuration is present.")
