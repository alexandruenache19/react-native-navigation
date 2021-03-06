#import "TransitionDelegate.h"
#import "DisplayLinkAnimator.h"

@implementation TransitionDelegate {
    RCTUIManager* _uiManager;
    id <UIViewControllerContextTransitioning> _transitionContext;
    BOOL _animate;
}

- (instancetype)initWithUIManager:(RCTUIManager *)uiManager {
    self = [super init];
    _uiManager = uiManager;
    [_uiManager.observerCoordinator addObserver:self];
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _animate = YES;
    _transitionContext = transitionContext;
    [self prepareTransitionContext:transitionContext];
    
    UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (![fromVC.navigationController.childViewControllers containsObject:fromVC]) {
        [self performAnimationOnce];
    }
}

- (void)prepareTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.alpha = 0;
    [transitionContext.containerView addSubview:toVC.view];
}

- (void)performAnimationOnce {
    if (_animate) {
        _animate = NO;
        RCTExecuteOnMainQueue(^{
            id<UIViewControllerContextTransitioning> transitionContext = self->_transitionContext;
            UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            NSArray* transitions = [self createTransitionsFromVC:fromVC toVC:toVC containerView:transitionContext.containerView];
            [self animateTransitions:transitions andTransitioningContext:transitionContext];
        });
    }
}

- (void)animateTransitions:(NSArray<id<DisplayLinkAnimatorDelegate>>*)animators andTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    DisplayLinkAnimator* displayLinkAnimator = [[DisplayLinkAnimator alloc] initWithDisplayLinkAnimators:animators duration:[self transitionDuration:transitionContext]];
    
    [displayLinkAnimator setCompletion:^{
        if (![transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }
    }];
    
    [displayLinkAnimator start];
}

- (NSArray *)createTransitionsFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC containerView:(UIView *)containerView {
    @throw [NSException exceptionWithName:@"Unimplemented method" reason:@"createTransitionFromVC:fromVC:toVC:containerView must be overridden by subclass" userInfo:nil];
    return @[];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)uiManagerDidPerformMounting:(RCTUIManager *)manager {
    [self performAnimationOnce];
}

@end
