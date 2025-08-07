from fastmcp import FastMCP

from .config import DatabaseConfig
from .db_manager import DatabaseManager
from .validator import SecurityValidator
from .tools import execute_sql_tool, list_tables_tool, describe_table_tool

from .logger import logger


# Initialize FastMCP server
mcp = FastMCP("mysql_mcp_server_pro_plus")

# Module-level variables for database managers (initialized when server starts)
_db_manager = None
_security_validator = None


@mcp.resource("mysql://{table_name}/data")
async def read_table_data(table_name: str) -> str:
    """Read data from a MySQL table."""
    try:
        logger.info(f"Reading table data: {table_name}")

        global _db_manager, _security_validator
        if not _db_manager or not _security_validator:
            raise RuntimeError("Server not properly initialized")

        if not _security_validator._is_valid_table_name(table_name):
            raise ValueError(f"Invalid table name: {table_name}")

        result = await _db_manager.get_table_data(table_name)

        if not result.has_results:
            return "No data available"

        # Format results as CSV
        lines = [",".join(result.columns)]
        for row in result.rows:
            lines.append(",".join(str(cell) for cell in row))

        return "\n".join(lines)
    except Exception as e:
        logger.error(f"Error reading table {table_name}: {e}")
        raise RuntimeError(f"Failed to read table: {str(e)}")


@mcp.tool()
async def execute_sql(query: str) -> str:
    """Execute an SQL query on the MySQL server.

    Args:
        query: The SQL query to execute
    """
    global _db_manager, _security_validator
    return await execute_sql_tool(query, _db_manager, _security_validator)


@mcp.tool()
async def list_tables() -> str:
    """List all tables in the database."""
    global _db_manager
    return await list_tables_tool(_db_manager)


@mcp.tool()
async def describe_table(table_name: str) -> str:
    """Describe the structure of a table.

    Args:
        table_name: Name of the table to describe
    """
    global _db_manager, _security_validator
    return await describe_table_tool(table_name, _db_manager, _security_validator)


def main():
    """Main entry point to run the MCP server."""
    # Initialize database configuration and managers
    global _db_manager, _security_validator

    try:
        db_config = DatabaseConfig.from_env()
        _db_manager = DatabaseManager(db_config)
        _security_validator = SecurityValidator()

        # Log configuration (without sensitive data)
        logger.info("Starting MySQL MCP server...")
        logger.info(f"Database: {db_config.host}:{db_config.port}/{db_config.database}")
        logger.info(f"Charset: {db_config.charset}, Collation: {db_config.collation}")

        # Run the FastMCP server
        mcp.run(
            transport="streamable-http",
            port=8084,
            host="0.0.0.0",
        )

    except Exception as e:
        logger.error(f"Failed to start server: {e}", exc_info=True)
        raise
