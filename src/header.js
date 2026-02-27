import { onAuthChange } from './auth.js'

// Render header with dynamic user content
export function headerPartial(user) {
  const nav = document.querySelector('#nav')
  if (!nav) return
  
  const isAdmin = user?.email === 'your-email@example.com'
  
  nav.innerHTML = `
     <a href="/" class="logo-link">
    <img src="/logo1.png" alt="Arduino Store" class="logo">
  </a>
  <div class="nav-links">
    <a href="/"><img src="/public/home.png" alt="Home" class="nav-icon"></a>
    <a href="/products.html"><img src="/public/product.png" alt="Products" class="nav-icon"></a>
    ${isAdmin ? '<a href="/admin.html">Add</a><a href="/admin-manage.html">Manage</a>' : ''}
    ${user ? `<span class="user-name">Hi ${user.email.split('@')[0]}</span><button id="logout" class="btn-small">Logout</button>` : `<a href="/login.html">Login</a>`}
    <a href="/cart.html"><img src="/public/shopping-cart.png" alt="Cart" class="nav-icon"></a>
    ${user ? '<a href="/wishlist.html"><img src="/public/heart.png" alt="Wishlist" class="nav-icon"></a>' : ''}
  </div>
  `
  
  // Handle logout
  document.getElementById('logout')?.addEventListener('click', async () => {
    const { signOut } = await import('./auth.js')
    await signOut()
    location.reload()
  })
}

// Initialize header
onAuthChange(user => headerPartial(user))