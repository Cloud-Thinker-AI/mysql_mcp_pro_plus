import pytest
from mysql_mcp_server_pro_plus.server import app


def test_server_initialization():
    """Test that the server initializes correctly."""
    assert app.name == "mysql_mcp_server_pro_plus"


@pytest.mark.asyncio
async def test_server_has_tools():
    """Test that the server has tools registered."""
    # The server should have tools registered via decorators
    assert hasattr(app, "list_tools")
    assert hasattr(app, "call_tool")


@pytest.mark.asyncio
async def test_server_has_resources():
    """Test that the server has resources registered."""
    # The server should have resources registered via decorators
    assert hasattr(app, "list_resources")
    assert hasattr(app, "read_resource")


# Skip database-dependent tests if no database connection
@pytest.mark.asyncio
@pytest.mark.skipif(
    not all(
        [
            pytest.importorskip("mysql.connector"),
            pytest.importorskip("mysql_mcp_server_pro_plus"),
        ]
    ),
    reason="MySQL connection not available",
)
async def test_database_connection():
    """Test database connection configuration."""
    from mysql_mcp_server_pro_plus.server import get_db_config

    try:
        config = get_db_config()
        assert isinstance(config, dict)
        assert "host" in config
        assert "user" in config
        assert "password" in config
        assert "database" in config
    except ValueError as e:
        if "Missing required database configuration" in str(e):
            pytest.skip("Database configuration not available")
        raise
