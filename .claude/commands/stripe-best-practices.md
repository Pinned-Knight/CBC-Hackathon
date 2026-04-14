---
description: Stripe integration best practices — payment intents, subscriptions, webhooks, and error handling. Activate when implementing payments with Stripe.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Stripe Best Practices

## Setup
```bash
npm install stripe @stripe/stripe-js @stripe/react-stripe-js
```
```typescript
// lib/stripe.ts — server-side client
import Stripe from 'stripe'
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-06-20',
  typescript: true,
})

// lib/stripe-client.ts — client-side
import { loadStripe } from '@stripe/stripe-js'
export const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
```

## One-Time Payments (Payment Intent)
```typescript
// Server: create payment intent
export async function POST(req: Request) {
  const { amount, currency = 'usd' } = await req.json()
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100), // always in cents
    currency,
    automatic_payment_methods: { enabled: true },
    metadata: { userId: session.user.id },
  })
  return Response.json({ clientSecret: paymentIntent.client_secret })
}
```

```typescript
// Client: collect payment
import { PaymentElement, useStripe, useElements } from '@stripe/react-stripe-js'

function CheckoutForm() {
  const stripe = useStripe()
  const elements = useElements()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!stripe || !elements) return
    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: { return_url: `${window.location.origin}/success` },
    })
    if (error) toast.error(error.message)
  }

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button type="submit" disabled={!stripe}>Pay</button>
    </form>
  )
}
```

## Subscriptions
```typescript
// Create customer + subscription
async function createSubscription(userId: string, priceId: string, paymentMethodId: string) {
  const user = await userRepo.findById(userId)

  let customerId = user.stripeCustomerId
  if (!customerId) {
    const customer = await stripe.customers.create({ email: user.email, metadata: { userId } })
    customerId = customer.id
    await userRepo.update(userId, { stripeCustomerId: customerId })
  }

  await stripe.paymentMethods.attach(paymentMethodId, { customer: customerId })
  await stripe.customers.update(customerId, {
    invoice_settings: { default_payment_method: paymentMethodId }
  })

  return stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: 'default_incomplete',
    expand: ['latest_invoice.payment_intent'],
  })
}
```

## Webhooks (Critical)
```typescript
// app/api/webhooks/stripe/route.ts
export async function POST(req: Request) {
  const body = await req.text()
  const sig = req.headers.get('stripe-signature')!

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!)
  } catch {
    return new Response('Invalid signature', { status: 400 })
  }

  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSuccess(event.data.object as Stripe.PaymentIntent)
      break
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object as Stripe.Subscription)
      break
    case 'customer.subscription.deleted':
      await handleSubscriptionCanceled(event.data.object as Stripe.Subscription)
      break
    case 'invoice.payment_failed':
      await handlePaymentFailed(event.data.object as Stripe.Invoice)
      break
  }

  return new Response('OK', { status: 200 })
}
```

## Rules
- **Always use webhooks** to update your database — never rely on client-side redirects
- Never store card numbers — always use Stripe's tokenization
- Always use `Math.round(amount * 100)` for cent conversion
- Test with Stripe CLI: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
- Use test cards: `4242 4242 4242 4242` (success), `4000 0000 0000 9995` (decline)
- Idempotency keys for retried requests: `stripe.paymentIntents.create({...}, { idempotencyKey: orderId })`
