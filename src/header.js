import { onAuthChange } from './auth.js'

export function headerPartial(user) {
  const nav = document.querySelector('#nav')
  if (!nav) return
  
  // CHANGE THIS TO YOUR ACTUAL EMAIL
  const isAdmin = user?.email === 'akosibbear38@gmail.com'
  
  nav.innerHTML = `
    <nav>
      <a href="/">Home</a>
      <a href="/products.html">Products</a>
      ${isAdmin ? '<a href="/admin.html">Add</a><a href="/admin-manage.html">Manage</a>' : ''}
      ${user ? `<span>Hi ${user.email.split('@')[0]}</span><button id="logout">Logout</button>` : `<a href="/login.html">Login</a>`}
      <a href="/cart.html">Cart</a>
      ${user ? '<a href="/wishlist.html">♥</a>' : ''}
    </nav>
  `
  
  document.getElementById('logout')?.addEventListener('click', async () => {
    const { signOut } = await import('./auth.js')
    await signOut()
    location.reload()
  })
}

// Initialize header on load
onAuthChange(user => headerPartial(user))