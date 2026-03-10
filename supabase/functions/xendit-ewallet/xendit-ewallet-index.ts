const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { order_id, amount, channel_code, success_url, failure_url } = await req.json()

    const XND_KEY = 'xnd_development_ne8MRNIktUplZY6o6J5PRE6FKIifUmJ6s0rJfBHpfHvb5ZhAu5n055DsmEfHK'
    const XND_AUTH = 'Basic ' + btoa(XND_KEY + ':')

    const res = await fetch('https://api.xendit.co/ewallets/charges', {
      method: 'POST',
      headers: {
        'Authorization': XND_AUTH,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        reference_id: order_id.replace(/-/g, '').substring(0, 32),
        currency: 'PHP',
        amount: amount,
        checkout_method: 'ONE_TIME_PAYMENT',
        channel_code: channel_code,
        channel_properties: {
          success_redirect_url: success_url,
          failure_redirect_url: failure_url,
          cancel_redirect_url: failure_url,
        },
      }),
    })

    const data = await res.json()

    if (!res.ok) {
      return new Response(JSON.stringify({ error: data?.message || data?.error_code || 'Xendit error' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const checkoutUrl =
      data?.actions?.mobile_web_checkout_url ||
      data?.actions?.desktop_web_checkout_url ||
      (Array.isArray(data?.actions) && data.actions.find((a: any) => a.action === 'AUTH')?.url)

    return new Response(JSON.stringify({ checkout_url: checkoutUrl, charge: data }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
