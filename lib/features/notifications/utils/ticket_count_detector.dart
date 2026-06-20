bool hasTicketCountIncreased(int? storedCount, int currentCount) =>
    storedCount != null && currentCount > storedCount;
