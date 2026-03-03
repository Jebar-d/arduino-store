import { onAuthChange, supaAuth } from './auth.js'
import { getUnreadCount, subscribeToNotifications } from './notifications.js'

export function headerPartial(user) {
  const nav = document.querySelector('#nav')
  if (!nav) return
  
  const isAdmin = user?.email === 'your-email@example.com'
  
  nav.innerHTML = `
    <a href="/" class="logo-link">
      <img src="/logo1.png" alt="Arduino Store" class="logo">
    </a>
    <div class="nav-links">
      <a href="/"><img src="/home.png" alt="Home" class="nav-icon"></a>
      <a href="/products.html"><img src="/product.png" alt="Products" class="nav-icon"></a>
      ${isAdmin ? '<a href="/admin.html">Add</a><a href="/admin-manage.html">Manage</a>' : ''}
      ${user ? `
        <div class="nav-icon" onclick="toggleNotifications()" title="Notifications">
          <div class="bell-icon-placeholder"></div>
          <span class="notification-badge" id="notif-badge" style="display:none;">0</span>
        </div>
        <span class="user-name">Hi ${user.email.split('@')[0]}</span>
        <button id="logout" class="btn-small">Logout</button>
      ` : `<a href="/login.html"><img src="/user.png" alt="Login" class="nav-icon"></a>`}
      <a href="/cart.html"><img src="/shopping-cart.png" alt="Cart" class="nav-icon"></a>
      ${user ? '<a href="/wishlist.html"><img src="/heart.png" alt="Wishlist" class="nav-icon"></a>' : ''}
    </div>
  `
  
  if (user) {
    setupNotifications(user.id)
  }
  
  document.getElementById('logout')?.addEventListener('click', async () => {
    await supaAuth.auth.signOut()
    location.reload()
  })
}

async function setupNotifications(userId) {
  const { count } = await getUnreadCount(userId)
  updateBadge(count)
  
  subscribeToNotifications(userId, () => {
    updateBadge(parseInt(document.getElementById('notif-badge').textContent) + 1)
  })
}

function updateBadge(count) {
  const badge = document.getElementById('notif-badge')
  if (badge) {
    badge.textContent = count > 99 ? '99+' : count
    badge.style.display = count > 0 ? 'flex' : 'none'
  }
}

window.toggleNotifications = () => {
  const panel = document.getElementById('notification-panel')
  if (panel) {
    panel.remove()
  } else {
    showNotificationPanel()
  }
}

async function showNotificationPanel() {
  const { data: { session } } = await supaAuth.auth.getSession()
  if (!session) return
  
  const { data: notifications } = await getNotifications(session.user.id)
  
  const panel = document.createElement('div')
  panel.id = 'notification-panel'
  panel.className = 'notification-panel'
  
  panel.innerHTML = `
    <div class="notification-header">
      <h3>Notifications</h3>
      <button onclick="markAllRead()" class="btn-text">Mark all read</button>
    </div>
    <div class="notification-list">
      ${notifications?.length ? notifications.map(n => renderNotification(n)).join('') : '<p class="no-notifs">No notifications</p>'}
    </div>
  `
  
  document.body.appendChild(panel)
  
  setTimeout(() => {
    document.addEventListener('click', function close(e) {
      if (!panel.contains(e.target) && !e.target.closest('.notification-bell')) {
        panel.remove()
        document.removeEventListener('click', close)
      }
    })
  }, 100)
}

function renderNotification(n) {
  const icons = {
    welcome: '🎉',
    promo: '🏷️',
    wishlist_sale: '💰',
    cart_stock: '📦',
    system: '📢'
  }
  
  return `
    <div class="notification-item ${n.is_read ? 'read' : 'unread'}" data-id="${n.id}">
      <div class="notification-icon">${icons[n.type] || '🔔'}</div>
      <div class="notification-content" onclick="expandNotif('${n.id}')">
        <div class="notification-title">${n.title}</div>
        <div class="notification-preview">${n.message.substring(0, 60)}${n.message.length > 60 ? '...' : ''}</div>
        ${n.is_expanded ? `<div class="notification-full">${n.message}</div>` : ''}
        <div class="notification-meta">
          <span>${timeAgo(n.created_at)}</span>
          ${n.data?.action ? `<a href="${n.data.action}" class="notif-action">${n.data.action_text || 'View'}</a>` : ''}
        </div>
      </div>
      <button onclick="deleteNotif('${n.id}', event)" class="notif-delete">×</button>
    </div>
  `
}

function timeAgo(date) {
  const seconds = Math.floor((new Date() - new Date(date)) / 1000)
  if (seconds < 60) return 'just now'
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  return `${Math.floor(hours / 24)}d ago`
}

window.expandNotif = async (id) => {
  const item = document.querySelector(`[data-id="${id}"]`)
  const { supaDB } = await import('./db.js')
  
  await supaDB.from('notifications').update({ is_read: true }).eq('id', id)
  item.classList.remove('unread')
  item.classList.add('read')
}

window.markAllRead = async () => {
  const { data: { session } } = await supaAuth.auth.getSession()
  if (!session) return
  
  const { supaDB } = await import('./db.js')
  await supaDB.from('notifications').update({ is_read: true }).eq('user_id', session.user.id)
  
  document.getElementById('notif-badge').style.display = 'none'
  showNotificationPanel()
}

window.deleteNotif = async (id, event) => {
  event.stopPropagation()
  const { supaDB } = await import('./db.js')
  await supaDB.from('notifications').delete().eq('id', id)
  document.querySelector(`[data-id="${id}"]`)?.remove()
}