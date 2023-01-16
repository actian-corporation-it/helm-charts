import { chromium } from 'k6/x/browser';
import { check } from 'k6';
import { response } from 'k6/x/browser';

export const options = {
  thresholds: {},
  scenarios: {
    IMLoginProduction: {
      exec: 'im_login_production',
      executor: 'shared-iterations',
      gracefulStop: '30s',
      maxDuration: '10m',
      vus: 1,
      iterations: 1
    }
  }
}

export function im_login_production() {
  console.log('log')
  console.debug('debug')
  console.info('info')
  console.warn('warn')
  console.error('error')

  const browser = chromium.launch({
    headless: false,
    slowMo: '800ms' // slow down by 500ms
  });
  const context = browser.newContext();
  const page = context.newPage();

  // Goto front page, find login link and click it

  const resp = page.goto('https://console.im.actiandatacloud.com');
  check(resp, {
    'ResponseCodeIs200': (resp) => resp.status() == 200,
  });
  page.fill('input[placeholder="Username"]', __ENV.username);
  page.fill('input[placeholder="Password"]', __ENV.password);
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
  page.close();
  browser.close();
}

