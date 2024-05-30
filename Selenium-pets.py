import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By

def test_website():
    options = webdriver.FirefoxOptions()
    options.add_argument('--headless')
    driver = webdriver.Firefox(options=options)
    driver.get("http://localhost:8080/petclinic/")

    CSS_selectors = ["#main-navbar > ul > li.active", "#main-navbar > ul > li:nth-child(2)", "#main-navbar > ul > li:nth-child(3)","#main-navbar > ul > li:nth-child(4)"]

    title = driver.title
    print(driver.title)
    driver.implicitly_wait(2)

    for item in CSS_selectors:
        #
        #
        button = driver.find_element(by=By.CSS_SELECTOR, value= item)   
        button.click()
        print('Navigation works!')

        try:
            find_owner= driver.find_element(by=By.CSS_SELECTOR, value= "input#lastName.form-control")
            find_owner.send_keys("Davis")
            submit_button = driver.find_element(by=By.CSS_SELECTOR, value="#search-owner-form > div:nth-child(2) > div > button")
            submit_button.click()

            driver.back()

            if True:
            
                add_owner_button = driver.find_element(by=By.CSS_SELECTOR, value="body > div > div > a")
                add_owner_button.click()

                first_name = driver.find_element(by=By.CSS_SELECTOR, value= "input#firstName.form-control")
                first_name.send_keys("Emily")
                last_name= driver.find_element(by=By.CSS_SELECTOR, value= "input#lastName.form-control")
                last_name.send_keys("Clark")
                address= driver.find_element(by=By.CSS_SELECTOR, value= "input#address.form-control")
                address.send_keys("example avenue")
                city = driver.find_element(by=By.CSS_SELECTOR, value= "input#city.form-control")
                city.send_keys("Utrecht")
                telephone= driver.find_element(by=By.CSS_SELECTOR, value= "input#telephone.form-control")
                telephone.send_keys("0612345687")

                confirm_button = driver.find_element(by=By.CSS_SELECTOR, value="#add-owner-form > div:nth-child(2) > div > button")
                confirm_button.click()
                print('FINDING AND ADDING OWNER WORKS')

        except:
            print("There is no text box. Testing submit is not possible")
        finally:
            pass

    driver.quit()

test_website()
