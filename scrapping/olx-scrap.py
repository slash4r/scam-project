from general_functions import *
import pandas as pd


def fetch_offer_details_by_value(olx_offer: WebElement, value: str) -> WebElement or None or list:
    """
    Fetch the details of an OLX offer by a specific value. If the value is not found, return None.
    :param olx_offer: The WebElement containing the offer details.
    :param value: The CSS selector to locate the element(s).
    :return: WebElement, None, or list of WebElements.

    Example:
    fetch_offer_details_by_value(offer, 'h4.css-3hbl63').text
    """

    try:
        elements = olx_offer.find_elements(By.CSS_SELECTOR, value)

        if not elements:
            print_log('WARNING', f"No elements found for selector {value}.")
            return None

        if value == 'p.css-s7oag9':  # for location, employment_type, working_hours
            print_log('SUCCESS', f"Details extracted successfully for {value}!")
            return elements


        if value == 'span.css-17tytap': # for suitable_candidates, payment_type, experience, other
            print_log('SUCCESS', f"Details extracted successfully for {value}!")
            return elements

        print_log('SUCCESS', f"Single detail extracted successfully for {value}!")
        return elements[0]

    except Exception as e:
        print(
            "Im herererere"
        )
        print_log('ERROR', f"Error extracting details:\n{e}")
        return None


def process_page(chrome_driver: webdriver.Chrome, page_url: str, page_num: int) -> None:
    """
    Process the OLX page by extracting the details of the offers.
    :param chrome_driver: The WebDriver instance.
    :param page_url: The URL of the OLX page.
    :param page_num: The page number.
    :return: None but updates the DataFrame.

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

            class_s7oag9 = fetch_offer_details_by_value(offer, 'p.css-s7oag9')
            location = class_s7oag9[0] if class_s7oag9[0] else None
            employment_type = class_s7oag9[1] if class_s7oag9[1] else None
            working_hours = class_s7oag9[2] if class_s7oag9[2] else None

            suitable_candidates, payment_type, experience, with_accommodation, is_executive = None, None, None, False, False
            class_17tytap = fetch_offer_details_by_value(offer, 'span.css-17tytap')
            if class_17tytap:
                for web_element in class_17tytap:
                    try:
                        text_element = web_element.text
                    except Exception as e:
                        print_log('ERROR', f"Not text element in {class_17tytap}:\n{e}")
                        continue

                    if "кандидатам" in text_element.lower():
                        suitable_candidates = text_element
                    elif "оплата" in text_element.lower() or "ставк" in text_element.lower():
                        payment_type = text_element
                    elif "досвід" in text_element.lower():
                        experience = text_element
                    elif "проживанням" in text_element.lower():
                        with_accommodation = True
                    elif "посада" in text_element.lower():
                        is_executive = True

            link = fetch_offer_details_by_value(offer, 'a.css-13gxtrp')

            df.loc[len(df)] = [
                title.text if title else None,
                salary.text if salary else None,
                location.text if location else None,
                employment_type.text if employment_type else None,
                working_hours.text if working_hours else None,
                suitable_candidates,
                payment_type,
                experience,
                with_accommodation,
                is_executive,
                link.get_attribute('href') if link else None
            ]

            print_log('INFO', f"Finished processing offer in page №{page_num}.")
        except Exception as e:
            print_log('ERROR', f"Error processing offer in page №{page_num}:\n{e}")

driver: webdriver.Chrome = None

url = "https://www.olx.ua/uk/rabota/it-telekom-kompyutery/"

# init the dataframe
df = pd.DataFrame(columns=['Title',
                           'Salary',
                           'Location',
                           'Employment_Type',
                           'Working_hours',
                           'Suitable_candidates',
                           'Payment_type',
                           'Experience',
                           'With_accommodation',
                           'Is_executive',
                           'Link'])


def main():
    global driver
    driver = get_driver(mode='headless')

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
    df.to_csv('../data/olx_offers.csv', index=False)
    print_log('SUCCESS', r"Data saved to 'data/olx_offers.csv'.")

# updated process_page function
def test():
    global driver
    driver = get_driver(mode='windowed')  # windowed for debugging
    process_page(driver, url, 1)
    df.to_csv('../tests/test_olx_offers.csv', index=False)
    print_log('INFO', 'Test completed successfully!')


main()
print_log('WARNING', 'Press any key to close the browser...')
input()

driver.quit()
print_log('Info', 'Browser closed successfully.')
