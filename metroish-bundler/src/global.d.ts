export declare global {
    declare module globalThis {
        interface Global {
            [key: string]: any;
        }
    }
}
