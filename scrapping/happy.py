from scrapping.general_functions import *
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

    offers = chrome_driver.find_elements(By.CSS_SELECTOR, 'div.job_card')

    print_log('INFO', f"Processing page №{page_num} with {len(offers)} offers.")
    title_selector = 'div.job_card__title > a'
    salary_selector = 'div._location_more > span.job_plate._jobsalary'
    location_selector = 'span._joblocation'
    company_selector = 'a.job_card_company span'
    employment_type_selector = 'span._jobtype'
    # Extract details from each offer
    for offer in offers:

        try:
            # Initialize variables to None
            title, salary, location, employment_type = None, None, None, None

            title = fetch_offer_details_by_value(offer, title_selector)
            title_text = title.text if title else None

            try:
                salary = fetch_offer_details_by_value(offer, salary_selector)
                salary_text = salary.text if salary else None
            except AttributeError:
                salary_text = None
                print_log('ERROR', f"'NoneType' error while extracting salary.")

            try:
                location = fetch_offer_details_by_value(offer, location_selector)
                location_text = location.text if location else None
            except AttributeError:
                location_text = None
                print_log('ERROR', f"'NoneType' error while extracting location.")

            try:
                employment_type = fetch_offer_details_by_value(offer, employment_type_selector)
                employment_type_text = employment_type.text if employment_type else None
            except AttributeError:
                employment_type_text = None
                print_log('ERROR', f"'NoneType' error while extracting employment type.")

            try:
                company = fetch_offer_details_by_value(offer, company_selector)
                company_text = company.text if company else None
            except AttributeError:
                employment_type_text = None
                print_log('ERROR', f"'NoneType' error while extracting compny.")

            # Add the extracted data to the DataFrame
            df.loc[len(df)] = [
                title_text,
                salary_text,
                location_text,
                company_text,
                employment_type_text,
            ]
            print_log('SUCCESS', "Details extracted successfully!")

        except Exception as e:
            # Catch and log unexpected exceptions
            print_log('ERROR', f"Error processing offer in page №{page_num}:\n{e}")


driver = get_driver(mode='windowed') # windowed for debugging

url = "https://happymonday.ua/jobs-search/category=program-manager,project-manager,dyzajn,it,content-editor,lead-generator,seo_aso,analytics/"

# init the dataframe
df = pd.DataFrame(columns=['Title', 'Salary', 'Location', 'Company','Employment Type'])
# try:
#     driver.get(url)
#     driver.implicitly_wait(10)
#
#     # Extract max page number dynamically
#     pagination_element = driver.find_element(By.CSS_SELECTOR, 'ul.pagination')
#     page_links = pagination_element.find_elements(By.CSS_SELECTOR, 'li.page-item a')
#     page_numbers = [int(link.text) for link in page_links if link.text.isdigit()]
#     max_page_num = max(page_numbers, default=1)
#     print(max_page_num)
# except Exception as e:
#     print_log('ERROR', f"Failed to determine max pages. Defaulting to 1 page. Error: {e}")
#     max_page_num = 1

for page_num in range(1, 9):
    page_url = f"{url}page/{page_num}"
    process_page(driver, page_url, page_num)
print_log('INFO', 'All pages processed successfully!')

# Save the dataframe to a CSV file
df.to_csv('happy_offers3.csv', index=False)
print_log('SUCCESS', r"Data saved to 'data/olx_offers.csv'.")

print_log('WARNING', 'Press any key to close the browser...')
input()

driver.quit()
print_log('Info', 'Browser closed successfully.')