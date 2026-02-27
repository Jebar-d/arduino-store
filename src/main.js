import { onAuthChange } from './auth.js'
import { headerPartial } from './header.js'

// Initialize header on auth state change
onAuthChange(user => headerPartial(user))