import cancelBible from '../../../../src/routes/bible/cancel-bible';

import { build } from '../../../helper';
import { getPrismaInstance } from '@gu-example-system/exm-data-store-prisma';
import {
    seedData,
    clearData
} from './init-data/cancel-bible.seed.data';
import { mineAccountSeed, mineAccountClearData } from '../../../master-data/get-mine-account.hook.data';
import { getPermissionAndRoleSeed, getPermissionAndRoleClear } from '../../../master-data/getPermissionAndRole.hook.data';


import * as dotenv from 'dotenv';
dotenv.config({ path: __dirname + '/../../../../.env' })

const app = build(cancelBible);
process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/postgres?schema=fos_mine';

describe('cancel bible', () => {
    const prismaInstance = getPrismaInstance();

    beforeEach(async () => {
        await seedData(prismaInstance);
        await mineAccountSeed(prismaInstance);
        await getPermissionAndRoleSeed(prismaInstance);
    });

    afterEach(async () => {
        await getPermissionAndRoleClear(prismaInstance);
        await mineAccountClearData(prismaInstance)
        await clearData(prismaInstance);
    });




    it('failed: true, status: 400 stutas not public', async () => {
        const headers = {
            'By-Pass-Userid': 'id-from-gu-portal-mas-user',
            'By-Pass-Uid': 'id-from-gu-portal-mas-user',
        };
        const response = await app.inject({
            method: 'PUT',
            url: '/',
            headers: headers,
            body: {
                id: 'test-bible-1',
                cancelRemark: 'test'
            }

        });
        // Assert
        expect(response.statusCode).toBe(400)


    });

    it('success: true, status: 200', async () => {
        const headers = {
            'By-Pass-Userid': 'id-from-gu-portal-mas-user',
            'By-Pass-Uid': 'id-from-gu-portal-mas-user',
        };
        const response = await app.inject({
            method: 'PUT',
            url: '/',
            headers: headers,
            body: {
                id: 'test-bible-2',
                cancelRemark: 'test'
            }

        });
        // Assert
        expect(response.statusCode).toBe(200)

        // expect(responseData.success).toBeTruthy();
        // expect(responseData.data).toHaveProperty('items');
        // expect(responseData.data).toHaveProperty('total');
    });





});