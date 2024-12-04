from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from scrapping.general_functions import *
import pandas as pd
import time


def fetch_offer_details_by_value(olx_offer: WebElement, value: str) -> WebElement or None:
    try:
        output = olx_offer.find_element(By.CSS_SELECTOR, value)
        print_log('SUCCESS', f"Details extracted successfully!")
        return output
    except Exception as e:
        print_log('ERROR', f"Error extracting details:\n{e}")
        return None


def process_page(chrome_driver: webdriver.Chrome, page_url: str, page_num: int) -> None:
    # chrome_driver.get(page_url)
    # chrome_driver.implicitly_wait(10)
    offers = chrome_driver.find_elements(By.CSS_SELECTOR, 'div.card.h-70.w-100')
    print_log('INFO', f"Processing page №{page_num} with {len(offers)} offers.")
    title_selector = 'div.card-body h6.card-title'
    salary_selector = 'div.card-body h6.salary'
    location_selector = 'div.card-body div.footertitlestart span.footertitle'
    company_selector = "div.card-body div.footertitlestart:nth-of-type(2) span.footertitle"
    employment_type_selector = "div.card-body div.footertitlestart:nth-of-type(3) span.footertitle"
    site_selector = 'img.logoimg'
    # Extract details from each offer
    for offer in offers:
        try:
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
                company = fetch_offer_details_by_value(offer, company_selector)
                company_text = company.text if company else None
            except AttributeError:
                company_text = None
                print_log('ERROR', f"'NoneType' error while extracting .")

            try:
                employment_type = fetch_offer_details_by_value(offer, employment_type_selector)
                employment_type_text = employment_type.text if employment_type else None
            except AttributeError:
                employment_type_text = None
                print_log('ERROR', f"'NoneType' error while extracting employment type.")

            try:
                site = fetch_offer_details_by_value(offer, site_selector)
                site_text = site.get_attribute('src') if site else None
            except AttributeError:
                site_text = None
                print_log('ERROR', f"'NoneType' error while extracting site.")


            df.loc[len(df)] = [
                title_text,
                salary_text,
                location_text,
                company_text,
                employment_type_text,
                site_text
            ]
            print_log('SUCCESS', "Details extracted successfully!")

        except Exception as e:
            print_log('ERROR', f"Error processing offer in page №{page_num}:\n{e}")

    chrome_driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    time.sleep(2)  # Wait a moment for the page to load completely after scrolling

    # Wait for the "Next" button to be clickable and click it
    try:
        next_button = WebDriverWait(chrome_driver, 10).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, 'li.pagination-next a'))
        )
        next_button.click()
        print_log('INFO', 'Clicked the "Next" button.')
    except Exception as e:
        print_log('ERROR', f"Error clicking the 'Next' button:\n{e}")

driver = get_driver(mode='windowed') # windowed for debugging

url = "https://www.dcz.gov.ua/job"

# init the dataframe
df = pd.DataFrame(columns=['Title', 'Salary', 'Location','Company', 'Employment Type', 'Site'])

driver = webdriver.Chrome()

driver.get(url)


driver.implicitly_wait(5)
dropdown_trigger = driver.find_element(By.CSS_SELECTOR, "mat-select[placeholder='Оберіть галузь']")
dropdown_trigger.click()

# Locate and click the desired option ("IT") from the dropdown
it_option = driver.find_element(By.XPATH, "//mat-option/span[contains(text(), 'ІТ')]")
it_option.click()

search_button = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.XPATH, "//button[text()='Пошук']"))
)
driver.execute_script("arguments[0].click();", search_button)


time.sleep(2)

for page_num in range(1, 625):
    page_url = url
    process_page(driver, page_url, page_num)
print_log('INFO', 'All pages processed successfully!')





df.to_csv('govern_offers2.csv', index=False)
print_log('SUCCESS', r"Data saved to 'data/olx_offers.csv'.")

print_log('WARNING', 'Press any key to close the browser...')
input()

driver.quit()
print_log('Info', 'Browser closed successfully.')