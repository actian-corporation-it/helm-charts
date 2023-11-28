import { browser, version, response } from 'k6/experimental/browser';
import { check } from 'k6';

export const options = {
  tags: {
    k6cluster: __ENV.k6_cluster_name,
    testid: 'IntegrationManager_ConsoleLogin',
    env: __ENV.environment
  },
  thresholds: {},
  scenarios: {
    ActianDataPlatform_PlatformLogin: {
      exec: 'integration_manager_console_login',
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

export async function integration_manager_console_login() {
  const page = browser.newPage();

  console.info(`k6 browser version: (VU: ${__VU} - ITER: ${__ITER}) - `, browser.version());

  try {
    // Load main page and check HTTP status code
    const resp = await page.goto(__ENV.site_url, { waitUntil: 'load'});
    check(resp, {
      'ResponseCodeIs200': (resp) => resp.status() == 200,
    });


    // Fill in username and password
    page.locator('input[name="username"]').fill(__ENV.username);
    page.locator('input[name="password"]').fill(__ENV.password);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Username and password typed in`);


    // Wait for the Next button and click
    await Promise.all([
      page.locator('button[type="submit"]').waitFor(),
      page.locator('button[type="submit"]').click()
    ]);
    console.info(`Test step:  (VU: ${__VU} - ITER: ${__ITER}) - Login submitted`);


    // Check page content for keyword
    page.waitForTimeout(6000);
    const body = page.content();
    check(body, {
      'ContentHasKeyword': (body) => body.includes('All Jobs'),
    });
  } finally {
    // Close browser orderly and exit
    page.close();
  }
}

