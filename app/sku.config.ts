import type { SkuConfig } from 'sku';

export default {
  clientEntry: 'src/client.tsx',
  renderEntry: 'src/render.tsx',
  entrySideEffects: ['braid-design-system/reset'],
} satisfies SkuConfig;
