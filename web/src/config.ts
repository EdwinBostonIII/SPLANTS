const rawBaseUrl = (import.meta.env.VITE_API_BASE_URL as string | undefined) ?? '/api'
const sanitizedBaseUrl = rawBaseUrl.endsWith('/')
  ? rawBaseUrl.slice(0, -1) || '/api'
  : rawBaseUrl || '/api'

const rawApiKey = (import.meta.env.VITE_API_KEY as string | undefined) ?? ''

export const config = {
  apiBaseUrl: sanitizedBaseUrl,
  apiKey: rawApiKey.trim(),
}

export const buildApiUrl = (path: string) => {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`
  return `${config.apiBaseUrl}${normalizedPath}`
}

export type PublicFeatureFlags = {
  redis_enabled: boolean
  anthropic_enabled: boolean
  webhooks_configured: boolean
  budget_enforced: boolean
  daily_limit_enforced: boolean
}

export type PublicConfigResponse = {
  api_key_configured: boolean
  openai_configured: boolean
  features: PublicFeatureFlags
}
