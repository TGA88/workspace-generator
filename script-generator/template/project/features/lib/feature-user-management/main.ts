// public surface ของ feature-user-management — export เฉพาะ page + type (frontend-structure §3)
// ไม่ export components/hooks/logic ภายใน — คนนอก feature ห้ามเจาะไฟล์ภายในตรง ๆ
export { UserManagementPage } from './pages/user-management/user-management.page';
export type { User, UserState, UserAction } from './types/user.type';
