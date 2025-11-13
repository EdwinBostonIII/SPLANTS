import { useState, useEffect, useCallback, useRef } from 'react'
import { CurrencyDollar, ChartBar, Warning, Bell, CheckCircle, XCircle } from '@phosphor-icons/react'
import { Card } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Input } from '@/components/ui/input'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { config, buildApiUrl } from '@/config'
import { usePublicConfig } from '@/hooks/use-public-config'
import { toast } from 'sonner'

export default function SettingsPage() {
  const monthlyBudget = 80
  const currentUsage = 42
  const usagePercent = (currentUsage / monthlyBudget) * 100

  const { data: publicConfig, error: publicConfigError, loading: publicConfigLoading, refresh: refreshPublicConfig } =
    usePublicConfig()
  const hasClientApiKey = Boolean(config.apiKey)
  const missingConfigItems = publicConfig
    ? [
        !publicConfig.api_key_configured ? 'system API key' : null,
        !publicConfig.openai_configured ? 'OpenAI API key' : null
      ].filter((item): item is string => Boolean(item))
    : []
  const featureFlags = publicConfig?.features
  const featureStatusItems = featureFlags
    ? [
        {
          key: 'redis',
          label: 'Redis cache',
          enabled: featureFlags.redis_enabled,
          description: 'Cuts AI spending 30-50% by reusing responses'
        },
        {
          key: 'anthropic',
          label: 'Multi-model AI',
          enabled: featureFlags.anthropic_enabled,
          description: 'Combines GPT-4 with Anthropic Claude for premium quality'
        },
        {
          key: 'webhooks',
          label: 'Webhooks configured',
          enabled: featureFlags.webhooks_configured,
          description: 'Automation endpoints ready for Zapier, Make, or custom apps'
        },
        {
          key: 'budget',
          label: 'Monthly budget limit',
          enabled: featureFlags.budget_enforced,
          description: 'Stops spending once the monthly AI budget is reached'
        },
        {
          key: 'daily-limit',
          label: 'Daily request limit',
          enabled: featureFlags.daily_limit_enforced,
          description: 'Guards against runaway usage spikes'
        }
      ]
    : []
  const missingConfigSummary =
    missingConfigItems.length === 0
      ? ''
      : missingConfigItems.length === 1
        ? missingConfigItems[0]
        : `${missingConfigItems.slice(0, -1).join(', ')} and ${missingConfigItems[missingConfigItems.length - 1]}`
  const showSetupAlert = !publicConfigLoading && missingConfigItems.length > 0
  const showConfigError = !publicConfigLoading && Boolean(publicConfigError)

  // Webhook settings state
  const [webhookSettings, setWebhookSettings] = useState({
    webhook_content_generated_url: '',
    webhook_content_published_url: '',
    webhook_daily_report_url: ''
  })
  const [isSaving, setIsSaving] = useState(false)
  const [loadingSettings, setLoadingSettings] = useState(true)

  const missingKeyWarningShown = useRef(false)

  // Load current webhook settings on mount
  const loadWebhookSettings = useCallback(async () => {
    if (!config.apiKey) {
      if (!missingKeyWarningShown.current) {
        toast.error('API key is not configured. Set VITE_API_KEY in web/.env to manage settings.')
        missingKeyWarningShown.current = true
      }
      setLoadingSettings(false)
      return
    }

    try {
      setLoadingSettings(true)
      const response = await fetch(buildApiUrl('/v1/system/settings'), {
        headers: {
          'X-API-Key': config.apiKey
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        const settings = data.settings || {}
        const fallbacks = data.environment_fallbacks || {}
        
        setWebhookSettings({
          webhook_content_generated_url: settings.webhook_content_generated_url?.value || fallbacks.webhook_content_generated_url || '',
          webhook_content_published_url: settings.webhook_content_published_url?.value || fallbacks.webhook_content_published_url || '',
          webhook_daily_report_url: settings.webhook_daily_report_url?.value || fallbacks.webhook_daily_report_url || ''
        })
      } else {
        toast.error('Failed to load webhook settings')
      }
    } catch (error) {
      toast.error('Failed to load webhook settings')
    } finally {
      setLoadingSettings(false)
    }
  }, [config.apiKey])

  useEffect(() => {
    loadWebhookSettings()
  }, [loadWebhookSettings])

  const saveWebhookSettings = async () => {
    if (!config.apiKey) {
      toast.error('API key is not configured. Set VITE_API_KEY in web/.env to save settings.')
      return
    }

    try {
      setIsSaving(true)
      const response = await fetch(buildApiUrl('/v1/system/settings'), {
        method: 'POST',
        headers: {
          'X-API-Key': config.apiKey,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(webhookSettings)
      })

      if (response.ok) {
        toast.success('Webhook settings saved successfully!')
        refreshPublicConfig()
        await loadWebhookSettings()
      } else {
        throw new Error('Failed to save settings')
      }
    } catch (error) {
      toast.error('Failed to save webhook settings')
    } finally {
      setIsSaving(false)
    }
  }

  const getProgressStyle = () => {
    if (usagePercent >= 95) return { backgroundColor: 'oklch(0.55 0.22 25)' }
    if (usagePercent >= 80) return { backgroundColor: 'oklch(0.65 0.20 50)' }
    return {}
  }

  const costBreakdown = [
    { name: 'AI Usage (GPT-4)', cost: 28, percent: 67 },
    { name: 'Server & Hosting', cost: 10, percent: 24 },
    { name: 'Database Storage', cost: 4, percent: 9 },
  ]

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold mb-2">Budget & Settings</h1>
        <p className="text-muted-foreground">Monitor costs and manage your configuration</p>
      </div>

      {showConfigError && (
        <Alert variant="destructive" className="border border-red-200 bg-red-50">
          <XCircle size={20} weight="fill" className="text-red-600" />
          <AlertTitle>Unable to load setup status</AlertTitle>
          <AlertDescription>{publicConfigError}</AlertDescription>
        </Alert>
      )}

      {!hasClientApiKey && (
        <Alert variant="default" className="border border-amber-200 bg-amber-50">
          <Warning size={20} weight="fill" className="text-amber-600" />
          <AlertTitle>Dashboard API key required</AlertTitle>
          <AlertDescription>
            Set <code>VITE_API_KEY</code> in <code>web/.env</code> so the dashboard can authenticate requests to
            protected endpoints.
          </AlertDescription>
        </Alert>
      )}

      {showSetupAlert && (
        <Alert variant="default" className="border border-amber-200 bg-amber-50">
          <Warning size={20} weight="fill" className="text-amber-600" />
          <AlertTitle>Complete your backend setup</AlertTitle>
          <AlertDescription>
            Configure your {missingConfigSummary} in <code>.env</code> and restart the backend. This keeps your SPLANTS
            instance secure and able to generate content.
          </AlertDescription>
        </Alert>
      )}

      <Card className="p-8 shadow-md">
        <div className="flex items-start justify-between mb-6">
          <div>
            <h3 className="text-2xl font-semibold mb-1">Monthly Budget</h3>
            <p className="text-muted-foreground">Track your spending against the $80/month budget</p>
          </div>
          <CurrencyDollar size={48} weight="fill" style={{ color: 'oklch(0.75 0.15 85)' }} />
        </div>

        <div className="space-y-4">
          <div className="flex items-baseline justify-between">
            <span className="text-4xl font-bold">${currentUsage}</span>
            <span className="text-xl text-muted-foreground">of ${monthlyBudget}</span>
          </div>

          <div className="space-y-2">
            <div className="relative h-4 w-full overflow-hidden rounded-full bg-muted">
              <div
                className="h-full transition-all duration-500 rounded-full"
                style={{
                  width: `${usagePercent}%`,
                  ...getProgressStyle()
                }}
              />
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">{usagePercent.toFixed(1)}% used</span>
              <span className="text-muted-foreground">${(monthlyBudget - currentUsage).toFixed(2)} remaining</span>
            </div>
          </div>

          {usagePercent >= 80 && (
            <div className={`flex items-start gap-3 p-4 rounded-lg ${
              usagePercent >= 95 ? 'bg-red-50 border border-red-200' : 'bg-amber-50 border border-amber-200'
            }`}>
              <Warning
                size={24}
                weight="fill"
                className={usagePercent >= 95 ? 'text-red-600' : 'text-amber-600'}
              />
              <div>
                <h4 className={`font-semibold mb-1 ${
                  usagePercent >= 95 ? 'text-red-900' : 'text-amber-900'
                }`}>
                  {usagePercent >= 95 ? 'Budget Almost Depleted' : 'Approaching Budget Limit'}
                </h4>
                <p className={`text-sm ${
                  usagePercent >= 95 ? 'text-red-700' : 'text-amber-700'
                }`}>
                  {usagePercent >= 95
                    ? 'You\'ve used nearly all of your monthly budget. Consider upgrading or reducing usage.'
                    : 'You\'re using more than 80% of your monthly budget. Monitor your usage carefully.'}
                </p>
              </div>
            </div>
          )}
        </div>
      </Card>

      {featureStatusItems.length > 0 && (
        <Card className="p-8 shadow-md">
          <div className="flex items-start justify-between mb-6">
            <div>
              <h3 className="text-2xl font-semibold mb-1">Configuration status</h3>
              <p className="text-muted-foreground">Optional safeguards and enhancements enabled in your backend</p>
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            {featureStatusItems.map((item) => (
              <div key={item.key} className="flex items-start gap-3 rounded-lg border border-border/60 p-4 bg-muted/20">
                {item.enabled ? (
                  <CheckCircle size={20} weight="fill" className="mt-1 text-emerald-600" />
                ) : (
                  <XCircle size={20} weight="fill" className="mt-1 text-muted-foreground" />
                )}
                <div>
                  <p className="font-semibold">{item.label}</p>
                  <p className="text-sm text-muted-foreground">{item.description}</p>
                </div>
              </div>
            ))}
          </div>
        </Card>
      )}

      <Card className="p-8 shadow-md">
        <div className="flex items-start justify-between mb-6">
          <div>
            <h3 className="text-2xl font-semibold mb-1">Webhook Integration</h3>
            <p className="text-muted-foreground">Connect to Zapier, Make, or other automation services</p>
          </div>
          <Bell size={48} weight="fill" style={{ color: 'oklch(0.60 0.15 250)' }} />
        </div>

        {loadingSettings ? (
          <div className="text-center py-8 text-muted-foreground">
            Loading webhook settings...
          </div>
        ) : (
          <div className="space-y-6">
            <div className="space-y-3">
              <label className="text-sm font-medium">
                Content Generated Webhook
                <span className="text-muted-foreground font-normal ml-2">
                  (Triggered when new content is created)
                </span>
              </label>
              <Input
                type="url"
                placeholder="https://hooks.zapier.com/hooks/catch/..."
                value={webhookSettings.webhook_content_generated_url}
                onChange={(e) => setWebhookSettings({
                  ...webhookSettings,
                  webhook_content_generated_url: e.target.value
                })}
                className="font-mono text-sm"
              />
              <p className="text-xs text-muted-foreground">
                Get webhook URLs from{' '}
                <a href="https://zapier.com" target="_blank" rel="noopener noreferrer" className="underline">
                  Zapier
                </a>
                ,{' '}
                <a href="https://make.com" target="_blank" rel="noopener noreferrer" className="underline">
                  Make
                </a>
                , or{' '}
                <a href="https://ifttt.com" target="_blank" rel="noopener noreferrer" className="underline">
                  IFTTT
                </a>
              </p>
            </div>

            <div className="space-y-3">
              <label className="text-sm font-medium">
                Content Published Webhook
                <span className="text-muted-foreground font-normal ml-2">
                  (Triggered when content is published to a platform)
                </span>
              </label>
              <Input
                type="url"
                placeholder="https://hooks.zapier.com/hooks/catch/..."
                value={webhookSettings.webhook_content_published_url}
                onChange={(e) => setWebhookSettings({
                  ...webhookSettings,
                  webhook_content_published_url: e.target.value
                })}
                className="font-mono text-sm"
              />
            </div>

            <div className="space-y-3">
              <label className="text-sm font-medium">
                Daily Report Webhook
                <span className="text-muted-foreground font-normal ml-2">
                  (Triggered once per day with usage summary)
                </span>
              </label>
              <Input
                type="url"
                placeholder="https://hooks.zapier.com/hooks/catch/..."
                value={webhookSettings.webhook_daily_report_url}
                onChange={(e) => setWebhookSettings({
                  ...webhookSettings,
                  webhook_daily_report_url: e.target.value
                })}
                className="font-mono text-sm"
              />
            </div>

            <div className="pt-4 flex items-center gap-3">
              <button
                onClick={saveWebhookSettings}
                disabled={isSaving || !hasClientApiKey}
                className="px-6 py-2.5 bg-primary text-primary-foreground rounded-lg font-semibold hover:opacity-90 transition-opacity disabled:opacity-50"
              >
                {isSaving ? 'Saving...' : 'Save Webhook Settings'}
              </button>
              {!isSaving && (
                hasClientApiKey ? (
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <CheckCircle size={16} weight="fill" className="text-green-600" />
                    <span>Changes saved automatically</span>
                  </div>
                ) : (
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Warning size={16} weight="fill" className="text-amber-600" />
                    <span>Add your dashboard API key to enable saving.</span>
                  </div>
                )
              )}
            </div>

            <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <h4 className="font-semibold text-blue-900 mb-2">How to use webhooks:</h4>
              <ol className="space-y-2 text-sm text-blue-700">
                <li>1. Create a webhook trigger in Zapier, Make, or IFTTT</li>
                <li>2. Copy the webhook URL they provide</li>
                <li>3. Paste it into one of the fields above</li>
                <li>4. Click "Save Webhook Settings"</li>
                <li>5. Your automation will now receive events from SPLANTS!</li>
              </ol>
            </div>
          </div>
        )}
      </Card>

      <Card className="p-8 shadow-md">
        <div className="flex items-start justify-between mb-6">
          <div>
            <h3 className="text-2xl font-semibold mb-1">Cost Breakdown</h3>
            <p className="text-muted-foreground">Where your budget is being spent</p>
          </div>
          <ChartBar size={48} weight="fill" style={{ color: 'oklch(0.60 0.15 85)' }} />
        </div>

        <div className="space-y-6">
          {costBreakdown.map((item) => (
            <div key={item.name} className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="font-medium">{item.name}</span>
                <span className="text-lg font-semibold">${item.cost}</span>
              </div>
              <Progress value={item.percent} className="h-2" />
              <div className="text-sm text-muted-foreground">{item.percent}% of total</div>
            </div>
          ))}
        </div>
      </Card>

      <Card className="p-8 shadow-md">
        <h3 className="text-2xl font-semibold mb-6">Usage Tips</h3>
        <div className="space-y-4 text-muted-foreground">
          <div className="flex gap-3">
            <div className="w-2 h-2 rounded-full bg-primary mt-2" />
            <p>Enable Redis caching to reduce AI costs by 30-50%</p>
          </div>
          <div className="flex gap-3">
            <div className="w-2 h-2 rounded-full bg-primary mt-2" />
            <p>Generate content in batches to optimize API usage</p>
          </div>
          <div className="flex gap-3">
            <div className="w-2 h-2 rounded-full bg-primary mt-2" />
            <p>Use shorter content lengths when appropriate to reduce costs</p>
          </div>
          <div className="flex gap-3">
            <div className="w-2 h-2 rounded-full bg-primary mt-2" />
            <p>Review and edit generated content before publishing to maintain quality</p>
          </div>
          <div className="flex gap-3">
            <div className="w-2 h-2 rounded-full bg-primary mt-2" />
            <p>Set up webhooks to automate your workflow with Zapier or Make</p>
          </div>
        </div>
      </Card>
    </div>
  )
}
