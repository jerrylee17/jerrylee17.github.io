export interface companyEarnings {
    actual: number | null;
    estimate: number | null;
    period: string;
    surprise: number | null;
    surprisePercent: number | null;
    symbol: string;
}