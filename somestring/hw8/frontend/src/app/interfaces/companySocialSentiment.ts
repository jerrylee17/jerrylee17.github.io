interface reddit {
    mention: number;
    positiveMention: number;
    negativeMention: number;
}

interface twitter {
    mention: number;
    positiveMention: number;
    negativeMention: number;
}

export interface companySocialSentiment {
    symbol: string;
    reddit: reddit[];
    twitter: twitter[];
}
