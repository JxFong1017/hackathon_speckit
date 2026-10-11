import { renderToString } from 'react-dom/server';
import { BraidProvider } from 'braid-design-system';
import seekJobs from 'braid-design-system/themes/seekJobs';
import type { Render } from 'sku';

import App from './App';

const seekSansStylesheet =
  'https://www.seek.com/static/shared-web/seeksans.css';

export default {
  renderApp: ({ SkuProvider }) =>
    renderToString(
      <SkuProvider>
        <BraidProvider theme={seekJobs}>
          <App />
        </BraidProvider>
      </SkuProvider>,
    ),
  renderDocument: ({ app, headTags, bodyTags }) => `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Transfer talent contracts</title>
    <link rel="stylesheet" href="${seekSansStylesheet}" />
    ${headTags}
  </head>
  <body>
    <div id="app">${app}</div>
    ${bodyTags}
  </body>
</html>
`,
} satisfies Render;
