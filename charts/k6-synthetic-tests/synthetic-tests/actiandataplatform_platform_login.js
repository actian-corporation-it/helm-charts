import { browser, version, response } from 'k6/experimental/browser';
import { check } from 'k6';

export const options = {
  tags: {
    k6cluster: __ENV.k6_cluster_name,
    testid: 'ActianDataPlatform_PlatformLogin',
    env: __ENV.environment
  },
  thresholds: {},
  scenarios: {
    ActianDataPlatform_PlatformLogin: {
      exec: 'actiandataplatform_platform_login',
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

export async function actiandataplatform_platform_login() {
  const page = browser.newPage();

  console.info(`k6 browser version: (VU: ${__VU} - ITER: ${__ITER}) - `, browser.version());

  try {
    // Load main page and check HTTP Status Code
    const resp = await page.goto(__ENV.site_url, { waitUntil: 'load' });
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


    // Fill in password
    page.locator('input[type="password"]').click(); // bring it into focus
    page.locator('input[type="password"]').type(__ENV.password);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - password typed in`);


    // Wait for the Login button and click
    await Promise.all([
      page.locator('button[type="submit"]').waitFor(),
      page.locator('button[type="submit"]').click(),
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

