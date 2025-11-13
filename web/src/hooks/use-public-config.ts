import { useCallback, useEffect, useState } from 'react'

import { buildApiUrl, PublicConfigResponse } from '@/config'

type UsePublicConfigState = {
  data: PublicConfigResponse | null
  loading: boolean
  error: string | null
}

const INITIAL_STATE: UsePublicConfigState = {
  data: null,
  loading: true,
  error: null,
}

export function usePublicConfig() {
  const [state, setState] = useState<UsePublicConfigState>(INITIAL_STATE)

  const fetchConfig = useCallback(
    async (signal?: AbortSignal) => {
      setState((prev) => ({ ...prev, loading: true, error: null }))

      try {
        const response = await fetch(buildApiUrl('/v1/config/public'), {
          signal,
          cache: 'no-store',
        })

        if (!response.ok) {
          throw new Error(`Request failed with status ${response.status}`)
        }

        const payload = (await response.json()) as PublicConfigResponse

        if (signal?.aborted) {
          return
        }

        setState({ data: payload, loading: false, error: null })
      } catch (error) {
        if (signal?.aborted) {
          return
        }

        const message =
          error instanceof Error ? error.message : 'Unable to load configuration information'

        setState({ data: null, loading: false, error: message })
      }
    },
    []
  )

  useEffect(() => {
    const controller = new AbortController()
    fetchConfig(controller.signal).catch(() => {
      // Errors are handled within fetchConfig; ignore promise rejection here.
    })

    return () => {
      controller.abort()
    }
  }, [fetchConfig])

  const refresh = useCallback(() => {
    fetchConfig().catch(() => {
      // Errors already captured in state; avoid bubbling.
    })
  }, [fetchConfig])

  return {
    data: state.data,
    loading: state.loading,
    error: state.error,
    refresh,
  }
}
