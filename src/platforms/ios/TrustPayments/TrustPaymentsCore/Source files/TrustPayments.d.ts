declare class TrustPayments {
    static instance(): TrustPayments;
    configure(
        username: string,
        gateway: string,
        environment: string,
        locale?: string,
        customTranslations?: any
    ): void;
    translation(key: string): string | null;
    updateEnvironment(env: string): void;
}

declare enum GatewayType {
    eu,
    euBackup,
    us,
    devbox
}

declare enum TPEnvironment {
    production,
    staging
}