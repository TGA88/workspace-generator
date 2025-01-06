import createBible from '../../../../src/routes/bible/create-bible';

import { build } from '../../../helper';
import { getPrismaInstance } from '@gu-example-system/exm-data-store-prisma';
import {
    seedData,
    clearData
} from './init-data/create.seed.data';
import { pscAccountSeed, pscAccountClearData } from '../../../master-data/get-psc-account.hook.data';
import { getPermissionAndRoleSeed, getPermissionAndRoleClear } from '../../../master-data/getPermissionAndRole.hook.data';


import * as dotenv from 'dotenv';
dotenv.config({ path: __dirname + '/../../../../.env' })

const app = build(createBible);
process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/postgres?schema=fos_psc';
describe('create bible', () => {

    const prismaInstance = getPrismaInstance();

    beforeEach(async () => {
        await seedData(prismaInstance);
        await pscAccountSeed(prismaInstance);
        await getPermissionAndRoleSeed(prismaInstance);
    });

    afterEach(async () => {
        await getPermissionAndRoleClear(prismaInstance);
        await pscAccountClearData(prismaInstance)
        await clearData(prismaInstance);
    });

    it('success: true, status: 200', async () => {
        const headers = {
            'By-Pass-Userid': 'id-from-gu-portal-mas-user',
            'By-Pass-Uid': 'id-from-gu-portal-mas-user',
        };
        const body = {
            country: { countryCode: 'TH', countryName: 'thailand' },
            year: 2024,
            species: { speciesCode: "species-code", speciesName: "species-name" },
            animalType: [{ animalTypeCode: 'test-animal-code', animalTypeName: 'test-animal-typeName' }],
            items: ['test-bible-med'],
            medType: { medTypeCode: "test-medType-code", medTypeName: "test-medType-name" },
            uid: 'uid-bible',
            createBy: 'test-create-by',

        }
        const response = await app.inject({
            method: 'POST',
            url: '/',
            headers: headers,
            body: body

        });
        // Assert
        console.log('response', response)
        expect(response.statusCode).toBe(200)

        // expect(responseData.success).toBeTruthy();
        // expect(responseData.data).toHaveProperty('items');
        // expect(responseData.data).toHaveProperty('total');
    });



    it('success: true, status: 422', async () => {
        const headers = {
            'By-Pass-Userid': 'id-from-gu-portal-mas-user',
            'By-Pass-Uid': 'id-from-gu-portal-mas-user',
        };
        const body = {
            country: { countryCode: 'TH', countryName: 'thailand' },
            year: 2024,
            species: { speciesCode: "species-code", speciesName: "species-name" },
            // animalType: [{ animalTypeCode: 'test-animal-code', animalTypeName: 'test-animal-typeName' }],
            items: ['test-bible-med'],
            medType: { medTypeCode: "test-medType-code", medTypeName: "test-medType-name" },
            uid: 'uid-bible',
            createBy: 'test-create-by',

        }
        const response = await app.inject({
            method: 'POST',
            url: '/',
            headers: headers,

            body: body

        });
        // Assert
        expect(response.statusCode).toBe(422)

        // expect(responseData.success).toBeTruthy();
        // expect(responseData.data).toHaveProperty('items');
        // expect(responseData.data).toHaveProperty('total');
    });






});