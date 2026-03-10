const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const {
      order_id,
      amount,
      channel_code,
      success_url,
      failure_url,
      payer_email,
      customer_name,
      items,
    } = await req.json()

    const XND_KEY = 'xnd_development_ne8MRNIktUplZY6o6J5PRE6FKIifUmJ6s0rJfBHpfHvb5ZhAu5n055DsmEfHK'
    const XND_AUTH = 'Basic ' + btoa(XND_KEY + ':')

    // Map channel to payment methods shown on Xendit's hosted page
    let paymentMethods
    if (channel_code === 'GCASH') {
      paymentMethods = ['GCASH']
    } else if (channel_code === 'PAYMAYA') {
      paymentMethods = ['PAYMAYA']
    } else if (channel_code === 'CARD') {
      paymentMethods = ['CREDIT_CARD', 'DEBIT_CARD']
    } else {
      paymentMethods = ['GCASH', 'PAYMAYA', 'CREDIT_CARD', 'DEBIT_CARD']
    }

    const invoiceBody = {
      external_id: order_id.replace(/-/g, '').substring(0, 50),
      amount: amount,
      currency: 'PHP',
      description: `Arduino Store Order #${order_id.substring(0, 8).toUpperCase()}`,
      success_redirect_url: success_url,
      failure_redirect_url: failure_url,
      payment_methods: paymentMethods,
      ...(payer_email ? { payer_email } : {}),
      ...(customer_name ? { customer: { given_names: customer_name, email: payer_email || '' } } : {}),
      ...(items && items.length ? {
        items: items.map((i) => ({
          name: i.name,
          quantity: i.qty,
          price: i.price,
          category: 'Electronics',
        }))
      } : {}),
    }

    const res = await fetch('https://api.xendit.co/v2/invoices', {
      method: 'POST',
      headers: {
        'Authorization': XND_AUTH,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(invoiceBody),
    })

    const data = await res.json()

    if (!res.ok) {
      return new Response(
        JSON.stringify({ error: data?.message || data?.error_code || 'Xendit invoice error' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ checkout_url: data.invoice_url, invoice: data }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})