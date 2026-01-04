import { onAuthChange } from './auth.js'
import { headerPartial } from './header.js'
onAuthChange(user => headerPartial(user))