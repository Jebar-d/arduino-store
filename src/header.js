export function headerPartial(user) {
  const nav = document.querySelector('#nav')
  if (!nav) return
  nav.innerHTML = `
    <a href="/">Home</a>
    <a href="/products.html">Products</a>
    ${
      user
        ? `<span>Hi ${user.email}</span> <button id="logout">Logout</button>`
        : `<a href="/login.html">Login</a>`
    }
    <a href="/cart.html">Cart <span id="badge">0</span></a>
  `
  document.getElementById('logout')?.addEventListener('click', async () => {
    const { signOut } = await import('./auth.js')
    await signOut()
    location.reload()
  })
}