from general_functions import *


def fetch_offer_details_by_value(olx_offer: WebElement, value: str) -> WebElement or None:
    """
    Fetch the details of an OLX offer by a specific value. If the value is not found, return None.
    :param olx_offer:
    :param value:
    :return: WebElement or None

    Example:
    fetch_offer_details_by_value(offer, 'h4.css-3hbl63').text
    """


    try:
        output = olx_offer.find_element(By.CSS_SELECTOR, value)
        print_log('SUCCESS', f"Details extracted successfully!")
        return output
    except Exception as e:
        print_log('ERROR', f"Error extracting details:\n{e}")
        return None


def process_page(chrome_driver: webdriver.Chrome, page_url: str, page_num: int) -> None:
    """
    Process the OLX page by extracting the details of the offers.
    :param chrome_driver: The WebDriver instance.
    :param page_url: The URL of the OLX page.
    :param page_num: The page number.
    :return: None

    Example:
    process_page(selenium_driver, url, 1)
    """

    chrome_driver.get(page_url)

    chrome_driver.implicitly_wait(10)

    offers = chrome_driver.find_elements(By.CSS_SELECTOR, 'div[data-cy="l-card"]')

    # Extract details from each offer
    for offer in offers:
        try:
            title = fetch_offer_details_by_value(offer, 'h4.css-3hbl63')
            salary = fetch_offer_details_by_value(offer, 'p.css-9i84wo')
            location = fetch_offer_details_by_value(offer, 'span.css-d5w927')
            employment_type = fetch_offer_details_by_value(offer, 'p.css-s7oag9')
            link = fetch_offer_details_by_value(offer, 'a.css-13gxtrp')
            print({
                "Title": title,
                "Salary": salary,
                "Location": location,
                "Employment Type": employment_type,
                "Link": link,
            })
        except Exception as e:
            print_log('ERROR', f"Error processing offer in page №{page_num}:\n{e}")


selenium_driver = get_driver(mode='windowed') # windowed for debugging

url = "https://www.olx.ua/uk/rabota/it-telekom-kompyutery/"

process_page(selenium_driver, url, 1)

input("Press Enter to close the browser...\n")

selenium_driver.quit()

print_log('Info', 'Browser closed successfully.')
