from general_functions import *
import pandas as pd

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

    print_log('INFO', f"Processing page №{page_num} with {len(offers)} offers.")

    # Extract details from each offer
    for offer in offers:
        try:
            title = fetch_offer_details_by_value(offer, 'h4.css-3hbl63')
            salary = fetch_offer_details_by_value(offer, 'p.css-9i84wo')
            location = fetch_offer_details_by_value(offer, 'span.css-d5w927')
            employment_type = fetch_offer_details_by_value(offer, 'p.css-s7oag9')
            link = fetch_offer_details_by_value(offer, 'a.css-13gxtrp')

            df.loc[len(df)] = [
                title.text if title else None,
                salary.text if salary else None,
                location.text if location else None,
                employment_type.text if employment_type else None,
                link.get_attribute('href') if link else None
            ]

            print_log('INFO', f"Finished processing offer in page №{page_num}.")
        except Exception as e:
            print_log('ERROR', f"Error processing offer in page №{page_num}:\n{e}")


driver = get_driver(mode='windowed') # windowed for debugging

url = "https://www.olx.ua/uk/rabota/it-telekom-kompyutery/"

# init the dataframe
df = pd.DataFrame(columns=['Title', 'Salary', 'Location', 'Employment Type', 'Link'])

# find the number of pages
try:
    driver.get(url)

    driver.implicitly_wait(10)

    # Locate the pagination element
    pagination_element = driver.find_element(By.CSS_SELECTOR, 'ul.pagination-list')

    # Find all page number elements within the pagination list
    page_links = pagination_element.find_elements(By.CSS_SELECTOR, 'li[data-testid="pagination-list-item"] a')

    # Extract the text (page numbers) and convert them to integers
    page_numbers = [int(link.text) for link in page_links if link.text.isdigit()]

    # Return the largest page number or 0 if the list is empty
    max_page_num = max(page_numbers, default=0)
    print_log('INFO', f"Max page number: {max_page_num}")
except Exception as e:
    print_log('ERROR', f"Error extracting page numbers:\n{e}")
    exit(96)

for page_num in range(1, max_page_num + 1):
    page_url = f"{url}?page={page_num}"
    process_page(driver, page_url, page_num)
print_log('INFO', 'All pages processed successfully!')

# Save the dataframe to a CSV file
df.to_csv('./data/olx_offers.csv', index=False)
print_log('SUCCESS', r"Data saved to 'data/olx_offers.csv'.")

print_log('WARNING', 'Press any key to close the browser...')
input()

driver.quit()
print_log('Info', 'Browser closed successfully.')
