using System;
using Xunit;
using Moq;
using PSServiceBus.Helpers;
using PSServiceBus.Enums;
using PSServiceBus.Exceptions;

namespace PSServiceBus.Tests
{
    public class SbSenderTests
    {
        [Theory]
        [InlineData(SbEntityTypes.Queue)]
        [InlineData(SbEntityTypes.Topic)]
        public void ConstructorThrowsNonExistentEntityExceptionIfEntityDoesNotExist(SbEntityTypes entityType)
        {
            Mock<ISbManager> sbManagerMock = new Mock<ISbManager>();
            sbManagerMock.Setup(x => x.QueueOrTopicExists(It.IsAny<string>(), entityType)).Returns(false);

            Assert.Throws<NonExistentEntityException>(() => new SbSender("fakeConnectionString", "fakeEntityPath", entityType, sbManagerMock.Object));
        }
    }
}
