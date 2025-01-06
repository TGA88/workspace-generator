export interface FastifyCustomHookRequest {
    veterinarianId: string
    veterinarianCode: string
    veterinarianName: string
    accountUsername: string
    accountId: string
    userLanguage: string
    userPermission: {
        countryCode: string[]
        speciesCode: string[]
        cvCode: string[]
        buCode: string[]
        orgCode: string[]
    }
    userRole: string[]
}