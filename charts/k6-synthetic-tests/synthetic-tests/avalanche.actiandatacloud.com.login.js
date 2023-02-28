import { chromium, version } from 'k6/x/browser';
import { check } from 'k6';
import { response } from 'k6/x/browser';

export const options = {
  tags: {
    k6cluster: __ENV.CLUSTER_NAME,
  },
  thresholds: {},
  scenarios: {
    AvalancheLoginProduction: {
      exec: 'avalanche_login_production',
      executor: 'shared-iterations',
      gracefulStop: '60s',
      maxDuration: '10m',
      vus: 3,
      iterations: 3
    }
  }
}

export async function avalanche_login_production() {
  console.info('info')

  const browser = chromium.launch({
    args: ['start-maximized'],
    headless: true,
    slowMo: '500ms' // slow down by 500ms
  });

  const context = browser.newContext();
  const page = context.newPage();

  console.info('xk6-browser version: ', version);

  try {
    // Goto main page, waittill page is loaded and check HTTP status code
    const resp = await page.goto('https://avalanche.actiandatacloud.com', { waitUntil: 'load'});
    check(resp, {
      'ResponseCodeIs200': (resp) => resp.status() == 200,
    });

    console.info("Goto page");

    // Wait for the input field to appear and fill in username
    // const i1 = await page.waitForSelector('input[id="username"]')
    // i1.type(__ENV.username)
    page.locator('input[id="username"]').type(__ENV.username);
    console.info("Type username");

    // Wait for the Next button with its class name to appear
    //await Promise.all([
    //  page.waitForNavigation(),
    page.locator('button[type="submit"]').click();
    //]);

    console.info("Next pressed");

    // Wait for the login container class on the next page
    page.waitForSelector('.login-container')
    // page.screenshot({ path: 'test/png/click_next.png'})

    console.info("Login container")

    // Wait for the Radio Button to choose community login and click it
    page.waitForSelector('.radio-controls.ng-star-inserted')
    await Promise.all([
      page.waitForNavigation(),
      page.locator('label[for="mat-radio-3-input"]').click(),
      // Click Login button
      page.locator('button[type="submit"]').click(),
    ]);

    console.info("Radio button 3 clicked and submitted")
    // page.screenshot({ path: 'test/png/radio3_button_clicked.png'})


    // Wait for the class that displays Email / Password input fields
    // enter values
    page.locator('input[placeholder="Email"]').fill(__ENV.username);
    page.locator('input[placeholder="Password"]').fill(__ENV.password);
    // page.screenshot({ path: 'test/png/filled_second_username.png'})

    console.info("username password entered")

    // Wait for the Log In button to be displayed properly and click
    await page.waitForSelector('.sfdc')
    await page.locator('.slds-button.slds-button--neutral.sfdc_button.uiButton').click()
    // page.screenshot({ path: 'test/png/click_login.png'})

    console.info("Login clicked")

    // Wait for the main user landing page to be displayed
    Promise.all([
      page.waitForNavigation(),
      page.waitForTimeout(3000),
      page.waitForLoadState()
    ])

    console.info("Page loaded");
    // page.screenshot({ path: 'test/png/page_loaded.png'})

    // Click Warehouses link to display all warehouses
    page.locator('a[href="/warehouse"]').click();
    page.waitForNavigation();
    // page.screenshot({ path: 'test/png/click_warehouses.png'})

    console.info("Warehouse clicked")

    // Check page content for a warehouse named DO-NOT-DELETE
    const body = page.content();
    check(body, {
      'ContentHasKeyword': (body) => body.includes('DO-NOT-DELETE'),
    });
  } finally { 
    // Close browser orderly and exit
    page.close();
    browser.close();
  }
}

