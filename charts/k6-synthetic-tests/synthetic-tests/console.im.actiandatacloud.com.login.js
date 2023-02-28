import { chromium, version } from 'k6/x/browser';
import { check } from 'k6';
import { response } from 'k6/x/browser';

export const options = {
  tags: {
    k6cluster: __ENV.CLUSTER_NAME,
  },
  thresholds: {},
  scenarios: {
    IMLoginProduction: {
      exec: 'im_login_production',
      executor: 'shared-iterations',
      gracefulStop: '60s',
      maxDuration: '10m',
      vus: 3,
      iterations: 3
    }
  }
}

export async function im_login_production() {
  console.info('info');

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
    const resp = await page.goto('https://console.im.actiandatacloud.com/dx/login', { waitUntil: 'load'});
    check(resp, {
      'ResponseCodeIs200': (resp) => resp.status() == 200,
    });
 
    page.locator('input[name="username"]').fill(__ENV.username);
    page.locator('input[name="password"]').fill(__ENV.password);

    Promise.all([
      page.waitForNavigation(),
      page.$('button[type="submit"]').click(),
    ]);

    Promise.all([
      page.waitForNavigation(),
      page.waitForTimeout(6000),
    ]);

    const body = page.content();
    check(body, {
      'ContentHasKeyword': (body) => body.includes('All Jobs'),
    });
  } finally {
    page.close();
    browser.close();
  }
}

