import { chromium } from 'k6/x/browser';
import { check } from 'k6';
import { response } from 'k6/x/browser';

export const options = {
  // tags: {
  //   cluster: __ENV.CLUSTER_NAME,
  // },
  thresholds: {},
  scenarios: {
    AvalancheLoginProduction: {
      exec: 'avalanche_login_production',
      executor: 'shared-iterations',
      gracefulStop: '30s',
      maxDuration: '10m',
      vus: 1,
      iterations: 1
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
    headless: true,
    slowMo: '800ms' // slow down by 500ms
  });
  const context = browser.newContext();
  const page = context.newPage();

  // Goto front page, find login link and click it

  const resp = page.goto('https://avalanche.actiandatacloud.com/');
  check(resp, {
    'ResponseCodeIs200': (resp) => resp.status() == 200,
  });
  page.$('input[id="username"]').type(__ENV.first_username);
  page.$('button[type="submit"]').click();
  page.$('app-avalanche-login').click();
  Promise.all([
    page.waitForNavigation(),
    page.$('label[for="mat-radio-3-input"]').click(),
  ]);
  Promise.all([
    page.waitForNavigation(),
    page.$('button[type="submit"]').click(),
  ]);
  page.waitForTimeout(3000);
  page.fill('input[placeholder="Email"]', __ENV.second_username);
  page.fill('input[placeholder="Password"]', __ENV.password);
  Promise.all([
    page.waitForNavigation(),
    page.$('button[type="button"]').click(),
  ]);
  Promise.all([
    page.waitForNavigation(),
    page.waitForTimeout(6000),
  ]);
  // console.warn(page.content());
  const body = page.content();
  check(body, {
    'ContentHasKeyword': (body) => body.includes('DO-NOT-DELETE'),
  });
  //console.warn(page.content());
  page.close();
  browser.close();
}

