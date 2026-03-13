import { onAuthChange, supaAuth } from './auth.js'
import { getUnreadCount, subscribeToNotifications } from './notifications.js'
import { supaDB } from './db.js'
import { updateToggleIcon } from './theme.js'

// SVG Icon helpers
const ICONS = {
  home:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>`,
  products:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>`,
  account:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>`,
  bell:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>`,
  cart:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>`,
  heart:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>`,
  contact:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13.8a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 3h3a2 2 0 0 1 2 1.72c.13.96.37 1.9.7 2.81a2 2 0 0 1-.45 2.11L7.91 10.6a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45c.91.33 1.85.57 2.81.7A2 2 0 0 1 21.5 18c.01-.03 0 3-.58 3z"/></svg>`,
  about:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`,
  faq:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`,
  terms:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>`,
  logout:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>`,
  add:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>`,
  manage:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>`,
  promo:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>`,
  menu:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>`,
  close:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>`,
  sun:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>`,
  moon:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>`,
  login:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>`,
}
const ic=(n,s=20)=>{const svg=ICONS[n];if(!svg)return '';return svg.replace('<svg ',`<svg width="${s}" height="${s}" `);}


export function headerPartial(user) {
  const nav = document.querySelector('#nav')
  if (!nav) return
  const isAdmin = !!(user && import.meta.env.VITE_ADMIN_EMAIL && user.email === import.meta.env.VITE_ADMIN_EMAIL)
  const displayName = user ? user.email.split('@')[0] : ''
  const initials = user ? user.email.substring(0,2).toUpperCase() : 'G'
  const currentPath = location.pathname
  const theme = document.documentElement.getAttribute('data-theme') || 'dark'

  nav.innerHTML = `
    <div class="header-inner">
      <button class="burger-btn" id="burger-btn" aria-label="Open Menu">${ic('menu',22)}</button>
      <a href="/" class="header-logo-center">
        <img src="/public/logo1.png" alt="Arduino Store" class="logo" onerror="this.src='/public/logo2.png'">
      </a>
      <div class="header-right">
        <button id="theme-toggle" class="icon-btn" onclick="toggleTheme()" title="Toggle theme">
          ${theme==='dark'?ic('sun',100):ic('moon',100)}
        </button>
        ${user
          ?`<button class="icon-btn notif-bell" onclick="toggleNotifications()" title="Notifications" style="position:relative;">${ic('bell',100)}<span class="notification-badge" id="notif-badge" style="display:none;">0</span></button>`
          :`<a href="/login.html" class="icon-btn" title="Login">${ic('login',24)}</a>`}
        <a href="/cart.html" class="icon-btn" title="Cart" style="position:relative;">${ic('cart',24)}<span class="cart-badge" id="cart-badge" style="display:none;">0</span></a>
        ${user?`<a href="/wishlist.html" class="icon-btn" title="Wishlist" style="position:relative;">${ic('heart',24)}<span class="wishlist-badge" id="wishlist-badge" style="display:none;">0</span></a>`:''}
      </div>
    </div>`

  injectSidebar(user,isAdmin,displayName,initials,currentPath)

  if(user){setupNotifications(user.id);setupCartBadge(user.id);setupWishlistBadge(user.id)}

  document.getElementById('burger-btn')?.addEventListener('click',()=>{
    document.getElementById('sidebar')?.classList.add('open')
    document.getElementById('sidebar-overlay')?.classList.add('open')
  })
}

function injectSidebar(user,isAdmin,displayName,initials,currentPath){
  document.getElementById('sidebar')?.remove()
  document.getElementById('sidebar-overlay')?.remove()

  const overlay=document.createElement('div')
  overlay.id='sidebar-overlay'; overlay.className='sidebar-overlay'
  overlay.onclick=()=>window.closeSidebar()

  const sb=document.createElement('aside')
  sb.id='sidebar'; sb.className='sidebar'

  const isHome=currentPath==='/'||currentPath.includes('index')
  const act=(path)=>path==='/'?isHome?'active':'':currentPath.includes(path.replace('/',''))?'active':''

  const navItem=(href,iconName,label,badgeId='')=>`
    <a href="${href}" class="s-item ${act(href)}" title="${label}">
      <span class="s-icon">${ic(iconName,20)}</span>
      <span class="s-label">${label}</span>
      ${badgeId?`<span class="s-badge" id="${badgeId}" style="display:none;">0</span>`:''}
    </a>`

  sb.innerHTML=`
    <div class="sidebar-top">
      <div class="sidebar-brand">
        <img src="/public/logo2.png" alt="Logo" class="s-logo" onerror="this.style.display='none'">
        <span class="s-brand-name">Arduino Store</span>
      </div>
      <button class="s-close-btn" onclick="closeSidebar()" title="Close">${ic('close',18)}</button>
    </div>
    ${user?`<div class="sidebar-user"><div class="s-avatar">${initials}</div><div class="s-user-info"><div class="s-name">${displayName}</div><div class="s-email">${user.email}</div></div></div>`
    :`<div class="sidebar-auth"><a href="/login.html" class="s-auth-btn primary">Login</a><a href="/signup.html" class="s-auth-btn">Sign Up</a></div>`}
    <nav class="sidebar-nav">
      ${navItem('/','home','Home')}
      ${navItem('/products.html','products','Products')}
      ${user?`<div class="s-divider"></div>
        ${navItem('/account.html','account','Account')}
        ${navItem('/account.html#notifications','bell','Notifications','sidebar-notif-badge')}
        ${navItem('/cart.html','cart','Cart','sidebar-cart-badge')}
        ${navItem('/wishlist.html','heart','Wishlist','sidebar-wishlist-badge')}`:''}
      <div class="s-divider"></div>
      ${navItem('/contact.html','contact','Contact Us')}
      ${navItem('/about.html','about','About')}
      ${navItem('/faq.html','faq','FAQ')}
      ${navItem('/terms.html','terms','Terms')}
      ${isAdmin?`<div class="s-divider"></div>
        ${navItem('/admin.html','manage','Admin Dashboard')}`:''}
    </nav>
    ${user?`<div class="sidebar-footer"><button class="s-logout-btn" id="sidebar-logout">${ic('logout',18)}<span class="s-label">Sign Out</span></button></div>`:''}`

  document.body.appendChild(overlay)
  document.body.appendChild(sb)

  // Logout handler with error handling
  document.getElementById('sidebar-logout')?.addEventListener('click',async(e)=>{
    e.preventDefault()
    try {
      await supaAuth.auth.signOut()
      // Clear any cached data
      localStorage.clear()
      sessionStorage.clear()
      // Redirect to home
      window.location.href = '/'
    } catch (err) {
      console.error('Logout error:', err)
      // Even if there's an error, clear cache and redirect
      localStorage.clear()
      sessionStorage.clear()
      window.location.href = '/'
    }
  })
}

// Global logout function for access from anywhere
window.logout = async () => {
  try {
    await supaAuth.auth.signOut()
    localStorage.clear()
    sessionStorage.clear()
    window.location.href = '/'
  } catch (err) {
    console.error('Logout error:', err)
    localStorage.clear()
    sessionStorage.clear()
    window.location.href = '/'
  }
}

window.closeSidebar=function(){
  document.getElementById('sidebar')?.classList.remove('open')
  document.getElementById('sidebar-overlay')?.classList.remove('open')
}

async function setupNotifications(userId){
  const{count}=await getUnreadCount(userId)
  updateNotifBadge(count)
  subscribeToNotifications(userId,()=>{
    const b=document.getElementById('notif-badge')
    updateNotifBadge(parseInt(b?.textContent||'0')+1)
  })
}
function updateNotifBadge(count){
  ['notif-badge','sidebar-notif-badge'].forEach(id=>{
    const b=document.getElementById(id);if(!b)return
    b.textContent=count>99?'99+':count
    b.style.display=count>0?'flex':'none'
  })
}
async function setupCartBadge(userId){
  const{data}=await supaDB.from('cart_items').select('qty').eq('user_id',userId)
  updateCartBadge(data?.reduce((s,i)=>s+(i.qty||0),0)||0)
}
export function updateCartBadge(count){
  ['cart-badge','sidebar-cart-badge'].forEach(id=>{
    const b=document.getElementById(id);if(!b)return
    b.textContent=count>99?'99+':count
    b.style.display=count>0?'flex':'none'
  })
}
async function setupWishlistBadge(userId){
  const{data}=await supaDB.from('wishlists').select('id').eq('user_id',userId)
  updateWishlistBadge(data?.length||0)
}
export function updateWishlistBadge(count){
  ['wishlist-badge','sidebar-wishlist-badge'].forEach(id=>{
    const b=document.getElementById(id);if(!b)return
    b.textContent=count>99?'99+':count
    b.style.display=count>0?'flex':'none'
  })
}

window.toggleNotifications=()=>{
  const p=document.getElementById('notification-panel')
  p?p.remove():showNotificationPanel()
}
async function showNotificationPanel(){
  const{data:{session}}=await supaAuth.auth.getSession()
  if(!session)return
  const{data:notifs}=await supaDB.from('notifications').select('*').eq('user_id',session.user.id).order('created_at',{ascending:false}).limit(20)
  const panel=document.createElement('div')
  panel.id='notification-panel'; panel.className='notification-panel'
  panel.innerHTML=`<div class="notification-header"><h3>Notifications</h3><button onclick="markAllRead()" class="btn-text">Mark all read</button></div><div class="notification-list">${notifs?.length?notifs.map(n=>renderNotif(n)).join(''):'<p class="no-notifs">No notifications yet</p>'}</div>`
  document.body.appendChild(panel)
  setTimeout(()=>{
    document.addEventListener('click',function close(e){
      if(!panel.contains(e.target)&&!e.target.closest('.notif-bell')){panel.remove();document.removeEventListener('click',close)}
    })
  },100)
}
function renderNotif(n){
  const typeIcons={
    welcome:`<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>`,
    promo:`<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>`,
    system:`<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`,
  }
  const ico=typeIcons[n.type]||typeIcons.system
  return `<div class="notification-item ${n.is_read?'read':'unread'}" data-id="${n.id}" onclick="expandNotif('${n.id}')">
    <div class="notification-icon">${ico}</div>
    <div class="notification-content">
      <div class="notification-title">${n.title||'Notification'}</div>
      <div class="notification-preview">${(n.message||'').substring(0,60)}${(n.message||'').length>60?'...':''}</div>
      <div class="notification-meta"><span>${timeAgo(n.created_at)}</span></div>
    </div>
    <button onclick="deleteNotif('${n.id}',event)" class="notif-delete"><svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>
  </div>`
}
function timeAgo(date){
  const s=Math.floor((new Date()-new Date(date))/1000)
  if(s<60)return 'just now'
  const m=Math.floor(s/60);if(m<60)return `${m}m ago`
  const h=Math.floor(m/60);if(h<24)return `${h}h ago`
  return `${Math.floor(h/24)}d ago`
}
window.expandNotif=async(id)=>{
  const el=document.querySelector(`[data-id="${id}"]`);if(!el)return
  await supaDB.from('notifications').update({is_read:true}).eq('id',id)
  el.classList.replace('unread','read')
  const{data:{session}}=await supaAuth.auth.getSession()
  if(session){const{count}=await getUnreadCount(session.user.id);updateNotifBadge(count)}
}
window.markAllRead=async()=>{
  const{data:{session}}=await supaAuth.auth.getSession();if(!session)return
  await supaDB.from('notifications').update({is_read:true}).eq('user_id',session.user.id).eq('is_read',false)
  updateNotifBadge(0)
  document.querySelectorAll('.notification-item.unread').forEach(el=>el.classList.replace('unread','read'))
}
window.deleteNotif=async(id,event)=>{
  event.stopPropagation()
  await supaDB.from('notifications').delete().eq('id',id)
  document.querySelector(`[data-id="${id}"]`)?.remove()
  const list=document.querySelector('.notification-list')
  if(list&&!list.querySelector('.notification-item'))list.innerHTML='<p class="no-notifs">No notifications yet</p>'
}