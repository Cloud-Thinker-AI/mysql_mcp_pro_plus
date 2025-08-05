-- MySQL MCP Server Pro Plus - Initialization Script
-- This script runs when the MySQL container starts for the first time

-- Create a sample table for testing
CREATE TABLE IF NOT EXISTS sample_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO sample_data (name, description) VALUES
    ('Test Item 1', 'This is a test item for the MCP server'),
    ('Test Item 2', 'Another test item to verify functionality'),
    ('Test Item 3', 'Third test item for comprehensive testing');

-- Create a table for MCP server logs (optional)
CREATE TABLE IF NOT EXISTS mcp_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level VARCHAR(10) NOT NULL,
    message TEXT NOT NULL,
    service VARCHAR(50) DEFAULT 'mcp_server'
);

-- Grant necessary permissions to the MCP user
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON mcp_database.* TO 'mcp_user'@'%';
FLUSH PRIVILEGES;

-- Show created tables
SHOW TABLES;
