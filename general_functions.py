# THIS FILE CONTAINS GENERAL FUNCTIONS THAT CAN BE USED IN THIS PROJECT
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement


def print_colored(string: str, color_code: str, end='\n', sep=' ') -> None:
    """
    Print a colored string to the console.
    :param string:
    :param color_code:
    :param end:
    :param sep:
    :return: printing colored string into console

    Example: print_colored("Logging messages uploaded successfully!", '92')
    """
    print(f"\033[{color_code}m{string}\033[00m", end=end, sep=sep)


def print_log(log_type: str, message: str, width: int = 7) -> None:
    """
    Print a log message with a timestamp and colored log level.
    :param log_type: ERROR, WARNING, SUCCESS, INFO
    :param message:
    :param width:
    :return: printing log message into console

    Example:
    print_log('ERROR', "Error transferring message: 'TonapiClient
    """

    color_map = {
        'ERROR': '91',  # Red
        'WARNING': '93',  # Yellow
        'SUCCESS': '92',  # Green
        'INFO': '96'  # Light Cyan
    }

    color_code = color_map.get(log_type, '97')  # Default to white if level is unknown
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Center the log level text within the specified width
    level_centered = log_type.upper().center(width)

    # Format the message
    formatted_message = f"{timestamp} | {level_centered} | {message}"

    # Print the message with the appropriate color
    print_colored(formatted_message, color_code)


def get_driver(os: str = "Windows") -> webdriver.Chrome:
    """
    Get the WebDriver instance based on the OS.
    Args:
        os (str): The operating system (Windows or Linux).
    Returns:
        WebDriver: The WebDriver instance.
    """
    # Configure WebDriver
    options = webdriver.ChromeOptions()
    # options.add_argument("--headless")  # Run in headless mode (no browser window)
    options.add_argument("--no-sandbox")  # Bypass OS security model
    options.add_argument("--disable-images")  # Don't load images for faster scraping

    try:
        selenium_driver = webdriver.Chrome(options=options)
        print_log("SUCCESS", "WebDriver instance created successfully.")
    except Exception as e:
        print_log("ERROR", f"Failed to create WebDriver instance:\n{e}")
        exit(69)
    return selenium_driver


print_log('SUCCESS', "Logging messages uploaded successfully!")


if __name__ == "__main__":
    print_log('ERROR', "Error transferring message: 'TonapiClient' object has no attribute '_TonapiClient__read_content'")
    print_log('WARNING', "Retrying transfer...")
    print_log('SUCCESS', "Messages transferred successfully!")
    print_log('INFO', "Found 1 recipients.")
    print_log('INFO', "Transferring from 1 wallets to 1 recipients...")
