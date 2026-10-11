import { hydrateRoot } from 'react-dom/client';
import { BraidProvider } from 'braid-design-system';
import seekJobs from 'braid-design-system/themes/seekJobs';

import App from './App';

export default () => {
  const root = document.getElementById('app');
  if (!root) {
    return;
  }

  hydrateRoot(
    root,
    <BraidProvider theme={seekJobs}>
      <App />
    </BraidProvider>,
  );
};
