def main():
    """Main entry point for the package."""
    from . import server

    server.main()


# Expose important items at package level
__all__ = ["main"]
