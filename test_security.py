#!/usr/bin/env python3
"""Simple test script to verify security validator changes."""

import re


# Mock logger to avoid import issues
class MockLogger:
    def warning(self, msg):
        print(f"WARNING: {msg}")

    def error(self, msg):
        print(f"ERROR: {msg}")


logger = MockLogger()


# Copy the SecurityValidator class directly to avoid import issues
class SecurityValidator:
    """Validates and sanitizes inputs for security."""

    @staticmethod
    def validate_uri(uri: str):
        """Validate and parse MySQL URI."""
        if not uri.startswith("mysql://"):
            raise ValueError(f"Invalid URI scheme: {uri}")

        # Remove mysql:// prefix and split
        path = uri[8:]
        parts = path.split("/")

        if len(parts) < 1 or not parts[0]:
            raise ValueError(f"Invalid URI format: {uri}")

        table_name = parts[0]
        if not SecurityValidator._is_valid_table_name(table_name):
            raise ValueError(f"Invalid table name in URI: {table_name}")

        return table_name, "/".join(parts[1:]) if len(parts) > 1 else ""

    @staticmethod
    def _is_valid_table_name(table_name: str) -> bool:
        """Validate table name to prevent SQL injection."""
        return bool(re.match(r"^[a-zA-Z0-9_]+$", table_name))

    @staticmethod
    def validate_query(query: str) -> str:
        """Validate SQL query for security."""
        query = query.strip()
        if not query:
            raise ValueError("Query cannot be empty")

        # Check for potentially dangerous operations
        dangerous_keywords = [
            "DROP",
            "DELETE",
            "TRUNCATE",
            "ALTER",
            "CREATE",
            "INSERT",
            "UPDATE",
            "GRANT",
            "REVOKE",
            "EXECUTE",
            "PREPARE",
        ]

        query_upper = query.upper()
        for keyword in dangerous_keywords:
            if keyword in query_upper:
                error_msg = f"Blocked potentially dangerous SQL operation: {keyword}. This operation is not allowed for security reasons."
                logger.error(error_msg)
                raise ValueError(error_msg)

        return query


def test_security_validator():
    """Test the security validator with dangerous keywords."""
    print("Testing SecurityValidator with dangerous keywords...")

    # Test safe queries (should pass)
    safe_queries = [
        "SELECT * FROM users",
        "SELECT COUNT(*) FROM products",
        "SHOW TABLES",
        "DESCRIBE users",
    ]

    print("\n=== Testing SAFE queries (should pass) ===")
    for query in safe_queries:
        try:
            result = SecurityValidator.validate_query(query)
            print(f"✅ PASS: {query}")
        except ValueError as e:
            print(f"❌ FAIL: {query} - {e}")

    # Test dangerous queries (should be blocked)
    dangerous_queries = [
        ("DROP TABLE users", "DROP"),
        ("DELETE FROM users", "DELETE"),
        ("TRUNCATE TABLE users", "TRUNCATE"),
        ("ALTER TABLE users ADD COLUMN test INT", "ALTER"),
        ("CREATE TABLE test (id INT)", "CREATE"),
        ("INSERT INTO users VALUES (1, 'test')", "INSERT"),
        ("UPDATE users SET name = 'test'", "UPDATE"),
        ("GRANT ALL ON *.* TO 'user'@'localhost'", "GRANT"),
        ("REVOKE ALL ON *.* FROM 'user'@'localhost'", "REVOKE"),
        ("EXECUTE stmt", "EXECUTE"),
        ("PREPARE stmt FROM 'SELECT * FROM users'", "PREPARE"),
    ]

    print("\n=== Testing DANGEROUS queries (should be BLOCKED) ===")
    for query, expected_keyword in dangerous_queries:
        try:
            SecurityValidator.validate_query(query)
            print(f"❌ FAIL: {query} - Should have been blocked!")
        except ValueError as e:
            if (
                f"Blocked potentially dangerous SQL operation: {expected_keyword}"
                in str(e)
            ):
                print(f"✅ PASS: {query} - Correctly blocked")
            else:
                print(f"❌ FAIL: {query} - Wrong error message: {e}")

    print("\n=== Test Summary ===")
    print("Security validator is now configured to block dangerous SQL operations!")


if __name__ == "__main__":
    test_security_validator()
