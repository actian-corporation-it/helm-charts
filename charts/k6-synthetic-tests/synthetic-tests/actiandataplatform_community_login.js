import { browser, version, response } from 'k6/experimental/browser';
import { check } from 'k6';

export const options = {
  tags: {
    k6cluster: __ENV.k6_cluster_name,
    testid: 'ActianDataPlatform_CommunityLogin',
    env: __ENV.environment
  },
  thresholds: {},
  scenarios: {
    ActianDataPlatform_CommunityLogin: {
      exec: 'actiandataplatform_community_login',
      executor: 'per-vu-iterations',
      gracefulStop: '60s',
      maxDuration: '10m',
      vus: 3,
      iterations: 1,
      options: {
        browser: {
          type: 'chromium',
        },
      },
    }
  }
}

export async function actiandataplatform_community_login() {
  const page = browser.newPage();

  console.info(`k6 browser version: (VU: ${__VU} - ITER: ${__ITER}) - `, browser.version());

  try {
    // Load main page and check HTTP Status Code
    const resp = await page.goto('https://avalanche.actiandatacloud.com', { waitUntil: 'load' });
    check(resp, {
      'ResponseCodeIs200': (resp) => resp.status() == 200,
    });
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Main page loaded`);


    // Fill in username
    page.locator('input[id="username"]').type(__ENV.username);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Initial username typed in`);


    // Wait for the Next button and click
    await Promise.all([
      page.locator('button[type="submit"]').waitFor(),
      page.locator('button[type="submit"]').click()
    ]);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Initial "Next" pressed`);


    // Wait for the login container class on the next page
    page.waitForSelector('.login-container');
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Main login container clicked`);


    // Wait for the Radio Button to choose community login and click it
    page.waitForSelector('.radio-controls.ng-star-inserted');
    await Promise.all([
      page.locator('label[for="mat-radio-3-input"]').waitFor(),
      page.locator('label[for="mat-radio-3-input"]').click(),
    ]);
    await Promise.all([
      // Click Login button
      page.locator('button[type="submit"]').waitFor(),
      page.locator('button[type="submit"]').click()
    ]);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Radio button 3 clicked and submitted`);


    // Wait for the class that displays Email / Password input fields and enter values
    page.waitForTimeout(3000);
    page.locator('input[placeholder="Email"]').fill(__ENV.username);
    page.locator('input[placeholder="Password"]').fill(__ENV.password);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Community username password typed in`);


    // Wait for the Log In button to be displayed properly and click
    await Promise.all([
      page.locator('.slds-button.slds-button--neutral.sfdc_button.uiButton').waitFor(),
      page.locator('.slds-button.slds-button--neutral.sfdc_button.uiButton').click(),
    ]);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Login submitted`);


    // Click Warehouses link to display all warehouses
    page.waitForTimeout(3000);
    await Promise.all([
      page.locator('a[href="/warehouse"]').waitFor(),
      page.locator('a[href="/warehouse"]').click()
    ]);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Warehouse clicked`);
    page.waitForTimeout(2500);


    // Check page content for a warehouse named DO-NOT-DELETE
    const body = page.content();
    check(body, {
      'ContentHasKeyword': (body) => body.includes('DO-NOT-DELETE'),
    });
  } finally {
    // Close browser orderly and exit
    page.close();
  }
}

