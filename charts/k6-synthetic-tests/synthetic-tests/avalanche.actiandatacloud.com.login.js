import { chromium } from 'k6/x/browser';
import { check } from 'k6';
import { response } from 'k6/x/browser';

export const options = {
  thresholds: {},
  scenarios: {
    AvalancheLoginProduction: {
      exec: 'avalanche_login_production',
      executor: 'shared-iterations',
      gracefulStop: '60s',
      maxDuration: '10m',
      vus: 5,
      iterations: 5
    }
  }
}

export function avalanche_login_production() {
  console.log('log')
  console.debug('debug')
  console.info('info')
  console.warn('warn')
  console.error('error')

  const browser = chromium.launch({
    args: ['start-maximized'],
    headless: true,
    slowMo: '500ms' // slow down by 500ms
  });
  const context = browser.newContext();
  const page = context.newPage();

  // Goto main page, waittill page is loaded and check HTTP status code
  const resp = page.goto('https://avalanche.actiandatacloud.com/')
  page.waitForLoadState()
  check(resp, {
    'ResponseCodeIs200': (resp) => resp.status() == 200,
  })


  // Wait for the input field to appear and fill in username
  const i1 = page.waitForSelector('input[id="username"]')
  i1.type(__ENV.username)

  // Wait for the Next button with its class name to appear
  page.waitForSelector('.btn.btn-primary.btn-icon.justify-content-center')
  page.locator('button[type="submit"]').click()

  // Wait for the login container class on the next page
  page.waitForSelector('.login-container')

  // Wait for the Radio Button to choose community login and click it
  page.waitForSelector('.radio-controls.ng-star-inserted')
  page.locator('label[for="mat-radio-3-input"]').click()
  // Click Login button
  page.locator('button[type="submit"]').click()

  // Wait for the class that displays Email / Password input fields
  // enter values
  page.waitForSelector('.siteforceSldsOneColLayout.siteforceContentArea')
  page.fill('input[placeholder="Email"]', __ENV.username);
  page.fill('input[placeholder="Password"]', __ENV.password);

  // Wait for the Log In button to be displayed properly and click
  page.waitForSelector('.sfdc')
  page.locator('.slds-button.slds-button--neutral.sfdc_button.uiButton').click()

  // Wait for the main user landing page to be displayed
  Promise.all([
    page.waitForNavigation(),
    page.waitForTimeout(3000),
    page.waitForLoadState()
  ])

  // Click Warehouses link to display all warehouses
  page.locator('a[href="/warehouse"]').click()
  page.waitForNavigation()

  // Check page content for a warehouse named DO-NOT-DELETE
  const body = page.content();
  check(body, {
    'ContentHasKeyword': (body) => body.includes('DO-NOT-DELETE'),
  });
 
  // Close browser orderly and exit
  page.close();
  browser.close();
}

