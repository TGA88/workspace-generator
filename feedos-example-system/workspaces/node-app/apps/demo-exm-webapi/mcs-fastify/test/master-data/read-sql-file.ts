import fs from 'fs';

/**
 * this function reads a sql file and returns an array of sql statements
 * Note: each element in the array is a sql statement
 * use in prisma.sql([...]) to execute the sql statements
 * @param filePath 
 * @returns string[]
 */
export default function readSqlFile(filePath: string): string[] {
    const sqls = fs
        .readFileSync(filePath)
        .toString()
        .split('\n')
        .filter((line) => line.indexOf('--') !== 0)
        .join('\n')
        .replace(/(\r\n|\n|\r)/gm, ' ') // remove newlines
        .replace(/\s+/g, ' ') // excess white space
        .split(';')
    return sqls
}
