#!/usr/bin/env python3
"""
Test script to verify connections to Qdrant and OpenAI
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


def test_qdrant():
    """Test connection to Qdrant"""
    try:
        from qdrant_client import QdrantClient

        url = os.getenv("QDRANT_URL", "http://localhost:6333")
        api_key = os.getenv("QDRANT_API_KEY")

        print(f"Connecting to Qdrant at {url}...")
        if url.startswith("http"):
            client = QdrantClient(url=url, api_key=api_key)
        else:
            client = QdrantClient(path=url)

        # Test connection by getting collections list
        collections = client.get_collections()

        print("✅ Successfully connected to Qdrant!")
        print(f"Available collections: {[c.name for c in collections.collections]}")
        return True
    except ImportError:
        print("❌ Error: qdrant-client not installed. Run: pip install qdrant-client")
        return False
    except Exception as e:
        print(f"❌ Error connecting to Qdrant: {str(e)}")
        return False


def test_openai():
    """Test connection to OpenAI API"""
    try:
        import openai

        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            print("❌ Error: OPENAI_API_KEY environment variable not set")
            return False

        print("Testing OpenAI embeddings API...")
        client = openai.OpenAI(api_key=api_key)

        # Test with a simple embedding request
        response = client.embeddings.create(
            model="text-embedding-3-small", input="Hello, world!"
        )

        if response.data and len(response.data) > 0:
            print("✅ Successfully connected to OpenAI API!")
            print(f"Embedding model: text-embedding-3-small")
            print(f"Embedding dimensions: {len(response.data[0].embedding)}")
            return True
        else:
            print("❌ Error: Received empty response from OpenAI API")
            return False
    except ImportError:
        print("❌ Error: openai package not installed. Run: pip install openai")
        return False
    except Exception as e:
        print(f"❌ Error connecting to OpenAI: {str(e)}")
        return False


if __name__ == "__main__":
    print("Testing connections for MCP Qdrant Server...\n")

    # Add Python-dotenv to requirements
    try:
        import dotenv

        print("✅ dotenv installed")
    except ImportError:
        print("❌ dotenv not installed. Installing...")
        os.system("pip install python-dotenv")

    qdrant_ok = test_qdrant()
    openai_ok = test_openai()

    print("\nSummary:")
    print(f"Qdrant connection: {'✅ OK' if qdrant_ok else '❌ Failed'}")
    print(f"OpenAI API connection: {'✅ OK' if openai_ok else '❌ Failed'}")

    if qdrant_ok and openai_ok:
        print("\n✨ All systems are ready! You can now run the MCP server.")
    else:
        print(
            "\n⚠️ Some tests failed. Please fix the issues before running the MCP server."
        )
